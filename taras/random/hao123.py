# Crawl hao123.com, gather all URLs

# -*- coding: utf-8 -*-
import os, sys, re, random, cPickle, traceback, urllib2, threading, urllib, time
from datetime import datetime, timedelta
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../third_party')

from BeautifulSoup import BeautifulSoup
from third_party import chardet
from util.log import _logger
from util import pbrowser
from util import util

class Hao123:
    def __init__(self):
        self.br = pbrowser.get_browser()        

    def _randsleep(self):
        sec = random.randint(1,10)
        _logger.debug('sleeping for %d seconds' % sec)
        time.sleep(sec)

    def crawl_second(self, url):
        self._randsleep()
        _logger.debug('openning url:%s' % url)
        html = self.br.open(url).read()
        soup = BeautifulSoup(util.convert_to_utf8(html, "gb2312"))        

        for anchor in soup.findAll('a'):
            try:
                href = anchor['href']
                # Ignore internal links
                if href[:4] != "http" or href.find('hao123.com') != -1:
                    continue
                self.output.write('  %s %s\n' % (href.encode('utf8'), anchor.text.encode('utf8')))
            except Exception, err:
                _logger.error('got error with anchor(%s): %s' % (str(anchor), err))

        self.output.write('\n')

    def crawl_first(self, url):
        self._randsleep()
        _logger.info('opening first tier url: %s' % url)
        html = self.br.open(url).read()
        soup = BeautifulSoup(util.convert_to_utf8(html, "gb2312"))
        _logger.info('processing page with title:%s' % soup.title.text)

        tds = soup.findAll('td', 'tdH')
        for td in tds:
            anchor = td.find('a')
            if anchor == None:
                continue
            _logger.info('crawling second tier category: %s (%s)'
                         % (anchor.text, anchor['href']))
            self.output.write('%s\n' % anchor.text.encode('utf-8'))
            self.crawl_second(pbrowser.abs_url(url, anchor['href']))
            

    def crawl(self, url):
        self.output = open('hao123.crawl%s' % datetime.now().date(), 'w')
        _logger.info('opening hao123 home page: %s' % url)
        html = self.br.open(url).read()
        soup = BeautifulSoup(util.convert_to_utf8(html, "gb2312"))

        for top_tier in soup.findAll('table', monkey='cool'):
            anchor = top_tier.find('a')
            _logger.info('crawling top tier category: %s (%s)'
                         % (anchor.text, anchor['href']))
            self.crawl_first(pbrowser.abs_url(url, anchor['href']))
        self.output.close()

if __name__ == "__main__":
    crawler = Hao123()
    crawler.crawl('http://www.hao123.com')
