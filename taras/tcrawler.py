import os, sys, re, random, cPickle, traceback, urllib, time, signal, multiprocessing
from selenium import selenium
from datetime import datetime, timedelta
from urlparse import urlparse
from functools import partial

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root

from util.log import _logger
from util import pbrowser, util
from sql_agent import Tweet, SQLAgent


def crawl_href(anchor, encoding, selenium):
    tweet = Tweet()
    tweet.href = anchor['href'].strip().encode('utf-8')
    tweet.title = anchor.text.strip().encode('utf-8')

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

def try_crawl_href(anchor, encoding, agent, selenium):
    _logger.debug('crawling anchor (%s), URL: %s' % (anchor.text.encode('utf-8'),
                                                     anchor['href'].encode('utf-8')))
    # filters
    # ignore bad-looking anchors
    if util.chinese_charactor_count(anchor.text.strip()) < 10:
        _logger.debug('too few chinese chars in anchor text, ignoring')
        return None

    # ignore same href crawled recently
    now = datetime.now()
    last_crawled_at = agent.get_last_crawl_time(anchor['href'].encode('utf-8'))
    if (now - last_crawled_at).days <= 30:
        _logger.debug('ignore %s, same href was crawled %d days ago' % (anchor['href'], (now - last_crawled_at).days))
        return None

    # ignore same title crawled recently
    last_crawled_at = agent.get_last_crawl_time_by_title(anchor.text.encode('utf-8'))
    if (now - last_crawled_at).days <= 30:
        _logger.debug('ignore %s, same title was crawled %d days ago' % (anchor['href'], (now - last_crawled_at).days))
        return None
    
    tweet = crawl_href(anchor, encoding, selenium)
    _logger.info('crawl_href finished, anchor-text:(%s)' % anchor.text.encode('utf-8'))
    return tweet

def recursive_crawl(url, encoding, selenium, agent, domain, terminate):
    last_crawl = agent.get_crawl_history(url)
    now = datetime.now()
    if (now - last_crawl).days <= 3:
        _logger.debug('ignore, recently crawled: %s' % str(last_crawl))
        return

    links = pbrowser.get_all_href(url, encoding)
    _logger.debug("processing %d links" % (len(links)))
    count = 0
    for idx, link in enumerate(links):
        # ignore href to different domain; accept all href if 'domain' is empty string
        if urlparse(link['href'].encode('utf-8')).netloc.find(domain) == -1:
            _logger.debug('ignore (%s), different from domain (%s)' %
                          (link['href'].encode('utf-8'), domain))
            continue

        tweet = None
        try:
            tweet = try_crawl_href(link, encoding, agent, selenium)
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

class CrawlerProcess(multiprocessing.Process):

    def __init__(self, sele, agent, tasks):
        multiprocessing.Process.__init__(self)
        self.agent = agent
        self.sele = sele
        self.tasks = tasks
        self.alive = multiprocessing.Value('I', 0)
        self.pending_queue = multiprocessing.Value('B', 0)
        self.heartbeat()

    def heartbeat(self, pending_queue=False):
        self.alive.value = int(time.mktime(datetime.now().timetuple()))
        self.pending_queue.value = 1 if pending_queue else 0

    def is_pending_queue(self):
        return self.pending_queue.value == 1

    def get_heartbeat(self):
        return datetime.fromtimestamp(self.alive.value)

    def process_hub(self, task):
        url = task['url']
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
            cur_url = link['href'].encode('utf-8')

            ttl = task['ttl'] - 1
            if ttl > 1:
                self.tasks.put({'url': cur_url,
                                'encoding': encoding,
                                'domain': domain,
                                'ttl': ttl})
            else:
                self.tasks.put({'anchor': link,
                                'encoding': encoding,
                                'ttl': ttl})

        try:
            self.agent.update_crawl_history(url)
        except Exception, err:
            _logger.error('failed to add crawl history to DB:%s' % err)
                
    def process_terminal(self, task):
        link = task['anchor']
        url = link['href'].encode('utf-8')
        _logger.info('processing terminal link, url:%s' % url)

        tweet = None
        try:
            tweet = try_crawl_href(link, task['encoding'], self.agent, self.sele)
        except Exception, err:
            _logger.error('crawl href failed: %s, %s' % (err, traceback.format_exc()))
            return

        if tweet != None:
            try:
                self.agent.add_crawled_tweet(url, tweet)
                _logger.debug('new tweed added to db, href: %s' % url)
            except Exception, err:
                _logger.error('failed to add crawled tweet to DB: %s' % err)


    def run(self):
        while True:
            task = self.tasks.get()
            self.heartbeat()
            _logger.debug("Got task:%s" % (task))

            try:
                if task['ttl'] > 1:
                    self.process_hub(task)

                elif task['ttl'] == 1:
                    self.process_terminal(task)
            except Exception, err:
                _logger.error('unexpected exception:%s, %s' % (err, traceback.format_exc()))
            self.heartbeat(pending_queue = True)

class Aster:
    def __init__(self, dbname, dbuser, dbpass, dbhost):
        self.db_name = dbname
        self.db_user = dbuser
        self.db_pass = dbpass
        self.db_host = dbhost

    def handle_int(self, signum, frame):
        if os.getpid() != self.root_pid:
            sys.exit(0)
        _logger.info('got signal(%d), will shutdown gracefully' % signum)
        self.shutdown()
        sys.exit(0)

    def shutdown(self):
        if hasattr(self, 'workers'):
            for worker in self.workers:
                self.kill_worker(worker)
                self.workers.remove(worker)

    def kill_worker(self, worker):
        try:
            worker.sele.stop()
        except Exception, err:
            _logger.error('failed to stop selenium from %s: %s' % (worker.name, err))
        try:
            worker.agent.stop()
        except Exception, err:
            _logger.error('failed to stop SQLAgent from %s: %s' % (worker.name, err))
        worker.terminate()

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
        tasks = multiprocessing.Queue()

        process_num = parallel
        _logger.info('will spawn %d processes' % process_num)
        self.workers = []
        for i in range(process_num):
            worker = CrawlerProcess(self._prepare_selenium(), self._prepare_agent(), tasks)
            _logger.info('%s created' % worker.name)
            worker.start()
            self.workers.append(worker)

        # Checking workers' life
        while True:
            # Get all prime source
            sources = self.agent.get_all_prime_source()

            for source in sources:
                tasks.put({'ttl': 3,
                           'url': source.base_url,
                           'domain': source.domain,
                           'encoding': source.encoding})

            _logger.info("%d task in queue" % tasks.qsize())
            now = datetime.now()
            for worker in self.workers:
                duration = util.total_seconds(now - worker.get_heartbeat())
                _logger.debug('worker %s inactive for %d seconds, pending_queue:%d' 
                              % (worker.name, duration, worker.is_pending_queue()))
                if not worker.is_pending_queue() and duration > 10 * 60:
                    _logger.info('terminating process(%s), last active: %s' % (worker.name, worker.get_heartbeat()))
                    self.kill_worker(worker)
                    self.workers.remove(worker)
                    worker = CrawlerProcess(self._prepare_selenium(), self._prepare_agent(), tasks)
                    self.workers.append(worker)
                    worker.start()
                    _logger.info('%s started' % worker.name)

            time.sleep(2 * 60)

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
    
    
