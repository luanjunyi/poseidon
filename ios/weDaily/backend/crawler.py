HOUR = 3600
SLEEP_IN_SEC = HOUR

import eventlet
eventlet.monkey_patch()
feedparser = eventlet.import_patched('feedparser')

import os, sys, traceback, time, socket
from datetime import datetime
from BeautifulSoup import BeautifulSoup

from eventlet.green import urllib2

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../../"))

from db import WeeSQLAgent
from util.log import _logger
from util import pbrowser




class FeedCrawler(object):
    def __init__(self, agent, pool):
        self.agent = agent
        self.pool = pool

    def grab_image(self, html, entry):

        wee_url = entry.link.encode('utf-8')
        soup = BeautifulSoup(html, fromEncoding="utf-8")
        img = soup.find('img', src=True)
        if img == None:
            _logger.debug("%s has no image inside" % wee_url)
            return
        url = img['src']

        _logger.debug('downloading image from %s' % url)
        try:
            br = pbrowser.get_browser()
            image = br.download_image(url, base_url = wee_url).read()
        except Exception, err:
            _logger.error("downloading image failed(%s), baseurl(%s): %s" % (url, wee_url, traceback.format_exc()))
            return

        try:
            self.agent.add_wee_image(wee_url, image)
            _logger.debug("imaged added for wee:%s" % wee_url)
        except Exception, err:
            _logger.error("db error, failed to add image for wee %s: %s" % (wee_url, err))

    def process_content(self, entry):
        _logger.debug("pool stat: %d working %d waiting" % (self.pool.running(), self.pool.waiting()))
        text = ''
        html = ''
        if entry.has_key('summary_detail'):
            content = entry.summary_detail
            if content.type == u"text/plain" and text == '':
                text = content.value.encode('utf-8')
            elif content.type == u"text/html" and html == '':
                html = content.value.encode('utf-8')
        elif entry.has_key('summary'):
            html = entry.summary.encode('utf-8')

        if html == '' and text == '':
            _logger.error("failed to get text for entry %s" % entry.link.encode('utf-8'))
        return text, html

    def process_entry(self, entry, source):
        _logger.debug("pool stat: %d working %d waiting" % (self.pool.running(), self.pool.waiting()))
        url = entry.link.encode('utf-8')
        if self.agent.wee_exists(url):
            _logger.debug("ignore existed wee with url:%s" % url)
            return

        _logger.debug("processing entry from (%s)" % url)
        title = entry.title.encode('utf-8')
        if entry.has_key('author'):
            author = entry.author.encode('utf-8')
        else:
            author = ''

        if entry.has_key('updated_parsed') and entry.updated_parsed != None:
            updated_time = int(time.mktime(entry.updated_parsed))
        else:
            updated_time = int(time.time()) # FeedParser doesn't understand the 'updated' field
                                                 # of this feed, neither can we. Probabaly some CJK chars.
        text, html = self.process_content(entry)
        if entry.has_key('tags'):
            tags = [tag.term.encode('utf-8') for tag in entry.tags]
        else:
            tags = []
        try:
            self.agent.add_wee(source['id'], url, title, text, html, updated_time, author, tags)
        except Exception, err:
            _logger.error("DB failed to add wee: %s" % traceback.format_exc())
        else:
            self.grab_image(html, entry)



    def fetch_source(self, source):
        _logger.debug("pool stat: %d working %d waiting" % (self.pool.running(), self.pool.waiting()))
        _logger.info( "crawling source id=%d url=%s" % (source['id'], source['url']))

        cur_time = int(time.time())
        last_crawl_time = source['last_crawl_time']
        if cur_time - last_crawl_time < HOUR:
            _logger.info("ignore source(%s), last crawled %d minutes ago" % 
                          (source['url'], (cur_time - last_crawl_time) / 60))
            return

        try:
            _logger.debug("fetching feed from (%s)" % source['url'])
            p = feedparser.parse(source['url'])
            _logger.debug("fetched from (%s)" % source['url'])
            if p.feed.has_key('updated_parsed') and p.feed.updated_parsed != None:
                cur_feed_time = int(time.mktime(p.feed.updated_parsed))
            else:
                cur_feed_time = int(time.time()) # FeedParser doesn't understand the 'updated' field
                                                 # of this feed, neither can we. Probabaly some CJK chars.
            db_feed_time = source['last_feed_time']
            if db_feed_time >= cur_feed_time:
                _logger.info("ignore source(%s), no new feed. Last feed:%s, cur feed:%s"
                              % (source['url'], datetime.fromtimestamp(db_feed_time), datetime.fromtimestamp(cur_feed_time)))
                self.agent.update_source_time(source)
            else:
                _logger.info("processing %d entries from %s" % (len(p.entries), source['url']))
                for entry in p.entries:
                    self.process_entry(entry, source)
                self.agent.update_source_time(source, cur_feed_time)
                _logger.debug("source(%s) updated: %s"
                              % (source['url'], datetime.fromtimestamp(cur_feed_time)))

            _logger.info("source(id=%d) success" % source['id'])
            _logger.debug("pool stat: %d working %d waiting" % (self.pool.running(), self.pool.waiting()))
        except Exception, err:
            _logger.error("crawling faild for source id=%d, %s: %s" % (source['id'], source['url'], traceback.format_exc()))

import code, traceback, signal
def debug(sig, frame):
    """Interrupt running process, and provide a python prompt for
    interactive debugging."""
    d={'_frame':frame}         # Allow access to frame object.
    d.update(frame.f_globals)  # Unless shadowed by global
    d.update(frame.f_locals)

    i = code.InteractiveConsole(d)
    message  = "Signal recieved : entering python shell.\nTraceback:\n"
    message += ''.join(traceback.format_stack(frame))
    i.interact(message)

def listen():
    signal.signal(signal.SIGUSR1, debug)  # Register handler


def main():
    listen()
    socket.setdefaulttimeout(120)
    agent = WeeSQLAgent('weDaily', 'junyi', 'admin123')
    agent.start()
    pool = eventlet.GreenPool(2000)
    crawler = FeedCrawler(agent, pool)
    loop_count = 1
    while True:
        agent.restart()
        sources =  agent.get_all_sources()
        for source in sources:
            pool.spawn_n(crawler.fetch_source, source)
        pool.waitall()


        _logger.info("loop %d finished, will sleep for %d seconds" % (loop_count,
                                                                      SLEEP_IN_SEC))
        loop_count += 1
        time.sleep(SLEEP_IN_SEC)
if __name__ == "__main__":
    main()
