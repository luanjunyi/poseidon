import os, sys, re, random, cPickle, traceback, urllib, time, signal
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




