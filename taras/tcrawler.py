import os, sys, re, random, cPickle, traceback, urllib, time, signal, multiprocessing
from selenium import selenium
from datetime import datetime, timedelta
from urlparse import urlparse
from functools import partial

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root

from util.log import _logger
from util import pbrowser, util
from sql_agent import Tweet, SQLAgent


def crawl_href(anchor_url, anchor_text, encoding, selenium):
    tweet = Tweet()
    tweet.href = anchor_url
    tweet.title = anchor_text

    # get content
    _logger.debug('extracting content from (%s)' % tweet.href)
    content = pbrowser.extract_main_body(tweet.href, selenium, encoding)
    if content == '': # we dare not to deal with article without words
        return None
    else:
        tweet.content = content.encode('utf-8')

    # get image
    _logger.debug('trying to grab the main image from webpage, hint:(%s)' % tweet.title)
    image_url = ''
    image = None

    try:
        image, image_url = pbrowser.get_main_image_with_hint(url = tweet.href,
                                                             hint = tweet.title,
                                                             selenium = selenium,
                                                             hint_encoding = encoding)
        _logger.debug('image url: %s' % image_url)
    except Exception, err:
        _logger.error('failed to grab image from %s: %s,%s' % (tweet.href, unicode(err).encode('utf-8'), traceback.format_exc()))

    tweet.image_bin = image
    if image_url != '':
        tweet.image_ext = os.path.splitext(image_url.encode('utf-8'))[1]
    else:
        tweet.image_ext = ''
    return tweet

def try_crawl_href(anchor_url, anchor_text, encoding, agent, selenium):
    _logger.debug('crawling anchor (%s), URL: %s' % (anchor_text, anchor_url))
    # filters
    # ignore bad-looking anchors
    if util.chinese_charactor_count(anchor_text.decode('utf-8')) < 10:
        _logger.debug('too few chinese chars in anchor text, ignoring')
        return None

    # ignore same href crawled recently
    if crawled_as_terminal(agent, anchor_url, anchor_text, 30):
        _logger.debug('ignore %s, same href was crawled %d days ago' % (anchor_url,
                                                                        (now - last_crawled_at).days))
        return None

    tweet = crawl_href(anchor_url, anchor_text, encoding, selenium)
    _logger.info('crawl_href finished, anchor-text:(%s)' % anchor_text)
    return tweet

def recursive_crawl(url, encoding, selenium, agent, domain, terminate):
    if crawled_as_hub(agent, url, day_limit=3):
        _logger.debug('ignore, recently(3 days) crawled as hub: %s'
                      % (url))
        return

    links = pbrowser.get_all_href(url, encoding)
    _logger.debug("processing %d links" % (len(links)))
    count = 0
    for idx, link in enumerate(links):
        # ignore href to different domain; accept all href if 'domain' is empty string
        if urlparse(link['href'].encode('utf-8')).netloc.find(domain) == -1:
            _logger.debug('ignore (%s), different from domain (%s)' %
                          (link['href'].text.encode('utf-8'), domain))
            continue

        tweet = None
        try:
            #tweet = try_crawl_href(link, encoding, agent, selenium)
            tweet = try_crawl_href(link['href'].encode('utf-8').lower(),
                                   link.text.encode('utf-8').strip(),
                                   encoding, agent, selenium)
        except Exception, err:
            _logger.error('crawl href failed: %s, %s' % (err, traceback.format_exc()))
            continue

        if tweet != None:
            count += 1
            try:
                agent.add_crawled_tweet(url, tweet)
                _logger.info('new tweed added to db, %d total, (%d / %d) prcessed' %
                             (count, idx, len(links)))
            except Exception, err:
                _logger.error('failed to add crawled tweet to DB: %s' % err)
    _logger.debug('%d tweets crawled' % count)


    if terminate > 1:
            # use as hub page
        for idx, link in enumerate(links):
            if urlparse(link['href'].encode('utf-8')).netloc.find(domain) == -1:
                _logger.debug('ignore (%s), different from domain (%s)' %
                              (link['href'].encode('utf-8'), domain))
                continue

            try:
                recursive_crawl(link['href'], encoding, selenium, agent,
                            domain, terminate - 1)
            except Exception, err:
                _logger.error('crawl next layer failed: %s, %s' % (err, traceback.format_exc()))

    try:
        agent.update_crawl_history(url)
    except Exception, err:
        _logger.error('failed to add crawl history to DB:%s' % err)

def crawled_as_hub(agent, url, day_limit=3):
    now = datetime.now()
    last_crawl = agent.get_crawl_history(url)
    return (now - last_crawl).days <= day_limit

def crawled_as_terminal(agent, url, anchor, day_limit=30):
    now = datetime.now()
    last_crawled_at = agent.get_last_crawl_time(url)
    if (now - last_crawled_at).days <= day_limit:
        return True

    last_crawled_at = agent.get_last_crawl_time_by_title(anchor)
    return (now - last_crawled_at).days <= day_limit

def in_task_queue(agent, url, anchor):
    return agent.url_in_crawler_task(url) or \
        agent.anchor_in_crawler_task(anchor) and anchor != ""



class CrawlerProcess(multiprocessing.Process):
    def __init__(self, sele, agent, shard_id, shard_count):
        multiprocessing.Process.__init__(self)
        self.agent = agent
        self.sele = sele
        self.alive = multiprocessing.Value('I', 0)
        self.pending_input = multiprocessing.Value('B', 1)
        self.shard_id = shard_id
        self.shard_count = shard_count

        self.heartbeat(pending_input=True)

    def heartbeat(self, pending_input=False):
        self.alive.value = int(time.mktime(datetime.now().timetuple()))
        self.pending_input.value = 1 if pending_input else 0

    def is_pending_input(self):
        return self.pending_input.value == 1

    def get_heartbeat(self):
        return datetime.fromtimestamp(self.alive.value)

    def process_hub(self, task):
        url = task['anchor_url']
        _logger.info('processing hub page, url:%s' % url)
        last_crawl = self.agent.get_crawl_history(url)
        now = datetime.now()
        if (now - last_crawl).days <= 3:
            _logger.debug('ignore, recently crawled: %s' % str(last_crawl))
            return

        domain = task['domain']
        encoding = task['encoding']
        links = pbrowser.get_all_href(url, encoding)
        _logger.debug("got %d links" % (len(links)))

        for idx, link in enumerate(links):
            if urlparse(link['href'].encode('utf-8')).netloc.find(domain) == -1:
                _logger.debug('ignore (%s), different from domain (%s)' %
                              (link['href'].encode('utf-8'), domain))
                continue

            # make tempoary source
            cur_url = link['href'].encode('utf-8').lower()
            cur_text = link.text.encode('utf-8').strip()

            if crawled_as_hub(self.agent, cur_url, day_limit=3):
                _logger.debug('ignore, recently(3 days) crawled as hub: %s'
                              % (cur_url))
                continue

            if crawled_as_terminal(self.agent, cur_url, cur_text, day_limit=30):
                _logger.debug('ignore, recently(3 days) crawled as terminal: %s'
                              % (cur_url))
                continue

            if in_task_queue(self.agent, cur_url, cur_text):
                _logger.debug('ignore, already added to task queue: %s'
                              % (cur_url))
                continue

            ttl = task['ttl'] - 1
            try:
                self.agent.add_crawler_task(anchor_url = cur_url,
                                            anchor_text = cur_text,
                                            encoding = encoding,
                                            domain = domain,
                                            ttl = ttl)
                _logger.debug('%s added to task in DB' % cur_url)
            except Exception, err:
                _logger.error('failed to add crawler task, url:(%s), %s' %
                              (cur_url, err))

        try:
            self.agent.update_crawl_history(url)
        except Exception, err:
            _logger.error('failed to add crawl history to DB:%s' % err)
                
    def process_terminal(self, task):
        anchor_text = task['anchor_text']
        anchor_url = task['anchor_url']
        _logger.info('processing terminal link, url:%s' % anchor_url)

        tweet = None
        try:
            tweet = try_crawl_href(anchor_url, anchor_text, task['encoding'], self.agent, self.sele)
        except Exception, err:
            _logger.error('crawl href failed: %s, %s' % (err, traceback.format_exc()))

        if tweet != None:
            try:
                self.agent.add_crawled_tweet(anchor_url, tweet)
                _logger.debug('new tweed added to db, href: %s' % anchor_url)
            except Exception, err:
                _logger.error('failed to add crawled tweet to DB: %s' % err)


    def run(self):
        while True:
            self.heartbeat(pending_input=True)
            self.agent.restart()
            tasks = self.agent.get_all_crawler_task()
            my_task = None
            for task in tasks:
                if task['id'] % self.shard_count == self.shard_id:
                    my_task = task
                    break
            if not my_task:
                _logger.debug('no task for process shard %d' % self.shard_id)
                time.sleep(10)
                continue

            self.heartbeat(pending_input=False)
            _logger.debug("Got task:%s" % (my_task))

            try:
                if task['ttl'] > 1:
                    self.process_hub(task)

                elif task['ttl'] == 1:
                    self.process_terminal(task)
            except Exception, err:
                _logger.error('unexpected exception with url(%s):%s, %s' % (task['anchor_url'], err, traceback.format_exc()))
            finally:
                try:
                    self.agent.remove_crawler_task(my_task['id'])
                    _logger.debug('task for (%s) removed from DB' % task['anchor_url'])
                except Exception, err:
                    _logger.error('failed to remove crawler task, url:%s' % task['anchor_url'])



class Aster:
    def __init__(self, dbname, dbuser, dbpass, dbhost):
        self.db_name = dbname
        self.db_user = dbuser
        self.db_pass = dbpass
        self.db_host = dbhost

    def handle_int(self, signum, frame):
        if os.getpid() != self.root_pid:
            return
        _logger.info('got signal(%d), will shutdown gracefully' % signum)
        self.shutdown()
        _logger.info('all process killed, will call exit(0)')
        sys.exit(0)

    def shutdown(self):
        self.agent.stop()
        if hasattr(self, 'workers'):
            for worker in self.workers:
                pid = worker.pid
                try:
                    self.kill_worker(worker)
                    _logger.info('child process %d killed' % pid)
                except Exception, err:
                    _logger.error('failed to kill child pid:%d, %s, it will become orphan' % (pid, err))
        self.workers = []

    def kill_worker(self, worker):
        try:
            worker.sele.stop()
        except Exception, err:
            _logger.error('failed to stop selenium from %d: %s' % (worker.pid, err))
        try:
            worker.agent.stop()
        except Exception, err:
            _logger.error('failed to stop SQLAgent from %d: %s' % (worker.pid, err))
        os.system('kill -9 %d' % worker.pid)

    def _prepare_agent(self):
        return SQLAgent(self.db_name, self.db_user, self.db_pass, self.db_host)

    def _prepare_selenium(self):
        sele_timeout_minute = 2
        sele = selenium('localhost', 4444, 'firefox', 'http://baidu.com')
        sele.start()
        sele.set_timeout(sele_timeout_minute * 60 * 1000)
        return sele

    def crawl_tweet_prime_daemon(self, parallel):
        # Set root process pid
        self.root_pid = os.getpid()
        print "root process pid: %d" % self.root_pid
        self.agent = self._prepare_agent()


        process_num = parallel
        _logger.info('will spawn %d processes' % process_num)
        self.workers = []
        for i in range(process_num):
            worker = CrawlerProcess(self._prepare_selenium(), self._prepare_agent(), i, parallel)
            worker.start()
            _logger.info('%s:%d created' % (worker.name, worker.pid))
            self.workers.append(worker)

        # Checking workers' life
        while True:
            self.agent.restart()

            # Get all prime source
            sources = self.agent.get_all_prime_source()
            for source in sources:
                if crawled_as_hub(self.agent, source.base_url, day_limit = 5) or \
                        in_task_queue(self.agent, source.base_url, ''):
                    continue
                try:
                    self.agent.add_crawler_task(anchor_url=source.base_url,
                                                anchor_text='',
                                                encoding=source.encoding,
                                                domain=source.domain,
                                                ttl=3)
                except Exception, err:
                    _logger.error("failed to add crawler task, url:(%s), %s"
                                  % (source.base_url, err))

            _logger.info("%d task in DB" % self.agent.crawler_task_count())
            print "%d task in DB" % self.agent.crawler_task_count()

            temp_list = []
            now = datetime.now()
            for worker in self.workers:
                duration = util.total_seconds(now - worker.get_heartbeat())
                _logger.debug('worker %d inactive for %d seconds, pending_input:%d' 
                              % (worker.pid, duration, worker.is_pending_input()))
                print 'worker %d inactive for %d seconds, pending_input:%d' \
                    % (worker.pid, duration, worker.is_pending_input())

            
                if not worker.is_pending_input() and duration > 10 * 60:
                    _logger.info('terminating process-%d(%d), last active: %s' % (worker.shard_id, worker.pid, worker.get_heartbeat()))
                    shard_id = worker.shard_id
                    self.kill_worker(worker)
                    worker = CrawlerProcess(self._prepare_selenium(), self._prepare_agent(), shard_id, parallel)
                    worker.start()
                    _logger.info('%s(%d) started' % (worker.name, worker.pid))

                temp_list.append(worker)
            self.workers = temp_list


            #time.sleep(2 * 60)
            time.sleep(10)

def usage():
    print """
             Usage: tcrawler.py -h(--mysql-host=) MYSQL-HOST -u(--user=) DB-USER -p(--passwd=) DB-PASSWORD -d(--database=) DB-NAME
          """
    sys.exit(2)

if __name__ == "__main__":
    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'h:u:p:d:s:a:c:m:', ['mysql-host=', 'user=', 'passwd=', 'database=', 'multi='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()

    dbname = 'taras'
    dbuser = 'taras'
    dbpass = 'admin123'
    dbhost = 'localhost'

    parallel = 10

    for opt, arg in opts:
        if opt in ('-h', '--mysql-host'):
            dbhost = arg
        if opt in ('-u', '--user'):
            dbuser = arg
        if opt in ('-p', '--passwd'):
            dbpass = arg
        if opt in ('-d', '--database'):
            dbname = arg
        if opt in ('-m', '--multi'):
            parallel = int(arg)


    if dbuser == "":
        print '-u(--user=) must be provided'
        usage()
    if dbname == "":
        print '-d(--database=) must be provided'
        usage()
    if dbpass == "":
        print '-p(--passwd=) must be provided'
        usage()
    if dbhost == "":
        print '-h(--mysql-host=) must be provided'
        usage()

    crawler = Aster(dbname, dbuser, dbpass, dbhost)
    signal.signal(signal.SIGINT, crawler.handle_int)
    crawler.crawl_tweet_prime_daemon(parallel)
    
    
