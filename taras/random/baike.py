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

class Baike:
    def __init__(self):
        self.br = pbrowser.get_browser()

    def _randsleep(self):
        sec = random.randint(1,10)
        _logger.debug('sleeping for %d seconds' % sec)
        time.sleep(sec)

    def _crawl_fourth(self, url):
        page = 1
        while True:
            _logger.debug('fourth layer page %d (%s)' % (page, url))
            page += 1
            self._randsleep()
            html = self.br.open(url).read()
            html = util.convert_to_utf8(html, 'gb2312')
            soup = BeautifulSoup(html)

            for td in soup.findAll('td', 'f'):
                self.output.write('      %s\n' % td.find('a').text.encode('utf-8'))
                self.output.flush()
            try:
                url = soup.find('font', 'f9').find(text=u"下一页").parent()['href']
            except:
                break
        

    def _crawl_thirdary(self, anchor):
        self.output.write('    %s\n' % anchor.text.encode('utf-8'))
        _logger.info('crawling fourth (%s)' % anchor['href'])
        try:
            self._crawl_fourth(anchor['href'])
        except Exception, err:
            _logger.error('fourth(%s) failed: %s' % (anchor['href'], err))

    def _crawl_secondary(self, div):
        tb = div
        self.output.write('  %s\n' % div.text.encode('utf-8'))
        while not hasattr(tb, 'name') or tb.name != u"table":
            tb = tb.nextSibling
        for third in tb.findAll('a'):
            _logger.info('crawling thirdary (%s)' % third.text)
            try:
                self._crawl_thirdary(third)
            except Exception, err:
                _logger.error('third(%s) failed: %s\n%s' % (third.text.encode('utf-8'), err, traceback.format_exc()))
        

    def _crawl_primary(self, anchor):
        self.output.write(anchor.text.encode('utf-8') + '\n')
        self._randsleep()
        html = self.br.open(anchor['href']).read()
        html = util.convert_to_utf8(html, 'gb2312')
        soup = BeautifulSoup(html)

        seconds = soup.findAll('div', 'dirtit')
        for second in seconds:
            _logger.info('crawling secondary category: (%s)' % second.text.encode('utf-8'))
            try:
                self._crawl_secondary(second)
            except Exception, err:
                _logger.error('secondary(%s) failed: %s' % (second.text.encode('utf-8'), err))

    def crawl(self, url):
        self.output = open('baike.crawl%s' % datetime.now().date(), 'w')
        _logger.info('opening baike home page: %s' % url)
        html = self.br.open(url).read()
        html = util.convert_to_utf8(html, 'gb2312')
        soup = BeautifulSoup(html)


        for item in  soup.find('div', id="classList").findAll('h2'):
            anchor = item.find('a')
            _logger.info('crawling primary category: (%s), %s' % (anchor.text.encode('utf-8'), anchor['href'].encode('utf-8')))
            try:
                self._crawl_primary(anchor)
            except Exception, err:
                _logger.error('primary category(%s) failed: %s'
                              % (anchor.text.encode('utf-8'), err))

        _logger.info('crawling finished')
        self.output.close()



if __name__ == "__main__":
    crawler = Baike()
    crawler.crawl('http://baike.baidu.com')
