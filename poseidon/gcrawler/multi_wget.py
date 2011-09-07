#! /usr/bin/python

__author__="johnx"
__date__ ="$Mar 15, 2011 8:49:39 PM$"
import sys, os
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../../')
from third_party.xoltar import threadpool as xthreading
from third_party.xoltar.functional import curry

class MWGetPool:
    def __init__(self, pool_size = 1):
        self._pool = xthreading.ThreadPool(maxThreads = pool_size)
    def push_urls(self, urls):
        rvs = []
        for url in urls:
            rvs.append(self._pool.put(curry(mwget, url), block = False))
        return rvs
    
    def wait(self):
        return self._pool.join()
    def empty(self):
        return self._pool.empty()
    def get_pool(self):
        return self._pool

def mwget(url):
#    from sys import stderr
#    print >> stderr, url
    try:
        from gcrawler import wget, CrawlerWGetError, _logger
        return url, wget(url)
    except CrawlerWGetError, err:
        _logger.error('gcrawler: wget failed for URL: ' + url)
        return url, None

if __name__ == "__main__":
    print "not for execution"
