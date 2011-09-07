# Crawl 265.com, Google's hao123

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

class G265:
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
                _logger.error('got error with anchor(%s): %s' % (str(a), err))

        self.output.write('\n')

    def crawl_layer(self, url, level):
        self._randsleep()

        prefix = '  ' * level
        _logger.info('opening layer url: %s' % url)
        html = self.br.open(url).read()
        soup = BeautifulSoup(util.convert_to_utf8(html, "gb2312"), fromEncoding="utf-8")
        _logger.info('processing page with title:%s' % soup.title.text)

        # get next level links
        children = {}
        for li in soup.find('div', id='TreeData').findAll('li', 'close'):
            a = li.find('a')
            children[a.text] = a['href']


        # grab links in current page
        for div in soup.find('div', id="BMain").findAll('div', 'subBM'):
            cate = div.find('h3').text
            if cate in self.owned:
                continue

            self.owned.add(cate)
            self.output.write(prefix + '%s\n' % cate.encode('utf8'))
            for li in div.find('ul', 'listUrl').findAll('li'):
                try:
                    a = li.find('a')
                    self.output.write(prefix * 2 + '%s %s\n' %
                                      (a['href'].encode('utf8'), a.text.encode('utf8')))
                except Exception, err:
                    _logger.error('error processing anchor(%s): %s' % (str(li), err))
    
            # grab links in next level, if any
            if cate in children:
                self.crawl_layer(children[cate], level + 1)
            

    def crawl(self, url):
        self.owned = set()
        self.output = open('265.crawl%s' % datetime.now().date(), 'w')
        _logger.info('opening 265 home page: %s' % url)
        html = self.br.open(url).read()
        soup = BeautifulSoup(util.convert_to_utf8(html, "gb2312"), fromEncoding='utf-8')

        for anchor in soup.find('div', id="siteCate").find('div', 'body').findAll('a'):
            _logger.info('crawling top tier category: %s (%s)'
                         % (anchor.text, anchor['href']))
            self.output.write('%s\n' % anchor.text.encode('utf8'))
            self.crawl_layer(pbrowser.abs_url(url, anchor['href']), 1)
        self.output.close()

if __name__ == "__main__":
    crawler = G265()
    crawler.crawl('http://www.265.com')
