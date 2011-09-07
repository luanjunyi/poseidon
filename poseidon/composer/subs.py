# This file is deprecated

import random
import urllib2
import re
from BeautifulSoup import BeautifulSoup

def get_sub(word):
    random.seed()
    candidates = None
    if random.randint(0, 1) == 0:
        candidates = get_antonym(word)
    else:
        candidates = get_synonyms(word)
    candidates = filter(lambda x: len(x) > 0, candidates)
    if len(candidates) == 0:
        return word
    index = random.randint(0, len(candidates) - 1)
    return re.sub(r'\(.*\)', '', str(candidates[index])).strip()
    

def _parse_from_web(url):
    headers = {'User-Agent': 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.13) Gecko/20101206 Ubuntu/10.10 (maverick) Firefox/3.6.13',
               'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
               'Accept-Language': 'en-us,en;q=0.5'}
    req = urllib2.Request(url=url, headers=headers)
    page = None
    try_count = 0
    while try_count <= 10:
        try:
            page = urllib2.urlopen(req).read()
            break
        except Exception, err:
            print 'failed' + str(try_count + 1) + 'times for url:' + url
            try_count += 1
    if page == None:
        return []
    soup = BeautifulSoup(page)
    equals = soup.findAll('span', 'equals')
    return [word.strip() for word in ','.join([equal.string for equal in equals]).split(',')]

def get_antonym(word):
    url = "http://www.synonym.com/antonym/" + word + '/'
    return _parse_from_web(url)

def get_synonyms(word):
    url = "http://www.synonym.com/synonym/" + word + '/'
    return _parse_from_web(url)

    
    
