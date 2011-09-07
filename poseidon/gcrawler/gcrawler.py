#! /usr/bin/python
import sys, os, time, random
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../')

from util import pbrowser
from util.util import load_class_by_name
from third_party.xoltar import threadpool as xthreading

from functools import partial
import cPickle

_config = None
_logger = None
_wget_pool = None

def crawl(keyword, count):
    """interface function of crawler for google
    """
    _logger.info('search request for:[%(keyword)s], count:[%(count)d]' % { 'keyword': keyword, 'count': count })
    urls, lazy_results = search_for_url(keyword, count)
    _logger.info('search_for_url returned %d results' % len(urls))

    results = []
    for item in lazy_results:
        item = item.eval()
        if item['content'] != '':
            results.append(item)

    _logger.info('gcrawler: finished search request for keyword: %(keyword)s, returning %(count)d htmls.' 
                 % { 'keyword': keyword, 'count': len(results) })
    with open("crawler_out", "wb") as output:
        cPickle.dump(results, output, -1)


def wget(url):
    br = pbrowser.get_browser()
    failure_count = 0
    max_try = int(_config['wget.retry'])
    content = ''
    while failure_count < max_try:
        try:
            response = br.open(url, timeout=8)
            content = response.read()
            break
        except Exception, err:
            failure_count += 1
            _logger.error('wget failed once, for URL: %(url)s: %(detail)s'
                        % {'url': url,
                           'detail': str(err)})

    if failure_count == max_try:
        _logger.error('wget permnantly failed after %d retries, url: %s.' % (max_try, url))
        return {'url': url, 'content': ''}

    return {'url':url, 'content':content}

def _add_url_to_threadpool(url, futures, pool):
    futures.append(pool.put(partial(wget, url), block = False))

def search_for_url(keyword, count):
    """this function handles logic of searching google
    """
    lazy_results = []
    _logger.info("starting %d threads" % int(_config['wget.concurrent']))
    wget_pool = xthreading.ThreadPool(maxThreads = int(_config['wget.concurrent']))

    # This is the multithread version, but it may result in deadlock
    urls = pbrowser.ask_google(keyword, count,
                               callback = partial(_add_url_to_threadpool, futures = lazy_results, pool = wget_pool),
                               sleep_min = 10,
                               sleep_max = 20)
    #urls = pbrowser.ask_google(keyword, count, callback=(lambda new_url: lazy_results.extend( (new_url, wget(new_url)) )))
    _logger.info('%d results returned by Google' % len(urls))
    #return urls
    return list(urls), lazy_results

# Call this interface to start a 'typical' crawl
def start_crawler(keyword, count):
    crawl(keyword, count)

#this function is for debugging lambda(s)
def _debug(*args, **kw):
    print args
    print kw
    return args, kw

if __name__ == "__main__":
    start_crawler(sys.argv[1], sys.argv[2])
else:
    from util.log import _logger
    from util.config import get_config
    _config = get_config('poseidon')


