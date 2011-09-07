from xml.etree import ElementTree
import sys, os, time, random
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../')
from util.log import _logger
from util.util import load_class_by_name
from gcrawler import gcrawler
from interpreter import interpreter
from composer import composer
from poster import poster

def main(spec):
    et = ElementTree.parse("task.conf")
    cases = et.findall('case')
    for case in cases:
        query = case.attrib['search']
        search_count = int(case.attrib['search-count'])
        compose_count = int(case.attrib['compose-count'])
        _logger.info('processing case, query=[%s]' % query)
        if spec['crawl']:
# Start crawler
            _logger.info('kicking off crawler, keyword=(%s), count=%d' % (query, search_count))
            gcrawler.start_crawler(keyword=query, count=search_count)
# Start interpretor
            _logger.info('kicking off interpreter')
            interpreter.interpret('crawler_out', 'interpret_out')
# Start composer
        if spec['compose']:
            _logger.info('start composing %d articles' % compose_count)
            link_info = {}
            for link in case.findall('link'):
                link_info[link.attrib['anchor']] = list()
                for href in link.findall('href'):
                    link_info[link.attrib['anchor']].append(href.text)
            composer.compose('interpret_out', 'composer_out', compose_count, link_info)
# Start poster
        if spec['post']:
            _logger.info('start posting')
            post_count = int(case.attrib['post-count'])
            poster.post_spam('composer_out', limit=post_count)

def usage():
    print 'Usage: run.py [-a(--all) | [-c(--crawl)] [-w(--compose)] [-p(--post)]]'

if __name__ == "__main__":
    spec = {'crawl': False,
            'compose': False,
            'post': False}
    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'acwph', ['all', 'crawl', 'compose', 'post', 'help'])
    except Exception, err:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-a', '--all'):
            for key in spec:
                spec[key] = True
        if opt in ('-c', '--crawl'):
            spec['crawl'] = True
        if opt in ('-w', '--compose'):
            spec['compose'] = True
        if opt in ('-p', '--post'):
            spec['post'] = True
        if opt in ('-h', '--help'):
            usage()
            sys.exit(0)

    if len(filter(lambda v: v == True, spec.values())) > 0:
        main(spec)
    else:
        usage()
