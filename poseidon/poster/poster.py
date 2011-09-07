#! /usr/bin/python
# -*- coding: utf-8 -*-

import sys, re, random, os
from os.path import abspath, dirname, sep
current_dirname = dirname(abspath(__file__)) + sep
sys.path.append(abspath(current_dirname + '../../'))

from poseidon.poster.config import load_config
from util.log import _logger
from third_party.BeautifulSoup import BeautifulSoup

# 1. config as variable
# 2. pre-login login
# 3. pre-post post
#
_eng_conf = {
    'baobaoeye.com':{
        'handler': 'dvbbs',
        'base_url': 'http://www.baobaoeye.com/club/',
        },
    'wordpress.com':{
        'handler': 'wp',
        }
}

def _get_titles(content):
    bs_content = BeautifulSoup(content.decode("utf-8"))
    words = filter(lambda word: word.lower().capitalize() == word.capitalize(),
                   filter(lambda word: len(word) > 4,
                          filter(lambda word: '_' not in word,
                                 re.sub(r'[^\w]', ' ', content).split())))
    try:
        title = ' '.join(random.sample(words, 3))
    except:
        title = 'Why so serious?'

    anchors = []
    if content != None and bs_content != None:
        anchors = [link.getString() for link in bs_content.findAll('a')]
    anchors = filter(lambda i: i != None and i != '', anchors)
    if len(anchors) > 0:
        title += ' ' + random.choice(anchors)
    return title

def _load_handlers():
    from poseidon.poster.handlers import dvbbs_handler, wp_handler
    handlers = {
        #'dvbbs': dvbbs_handler(),
        'wp': wp_handler(),
        }
    return handlers

def post_spam(input_file, limit=1000000000, verbose=False):

    if verbose:
        from datetime import datetime
        path = 'dump.' + str(datetime.now()).replace(' ', '_')
        os.mkdir(path)

    _editor_config = load_config('poster-account.conf')
    #init

    from util.pbrowser import get_browser
    browser = get_browser()

    from poseidon.composer.composer import parse_composed

    contents = parse_composed(input_file)

    handlers = _load_handlers()


    for count in range(limit):

        _logger.info('posting round %d' % (count + 1))

        for site_name in _editor_config:
            site_conf = _editor_config[site_name]
            config = {}
            config.update(_eng_conf[site_name])
            handler = handlers[config['handler']]
            _logger.debug('spamming [%s]...' % site_name)
            for login in site_conf['logins']:
                # skip if post limit exceeded
                if 'post-limit' in login and count >= int(login['post-limit']):
                    continue

                content = random.choice(contents)
                if content == None or content == '':
                    continue
                title = _get_titles(content)
                config = {
                    'title': title,
                    'content': content,
                    }
                config['username'] = login['username']
                config['password'] = login['password']
                config['base-url'] = login['base-url']

                success, html = handler.post_blog(browser, config)
                if success:
                    _logger.info('succeeded %s with %s:%s, base-url:%s' % (site_name, config['username'], config['password'], config['base-url']))
                else:
                    _logger.error('failed %s with %s:%s, base-url:%s' % (site_name, config['username'], config['password'], config['base-url']))
                if verbose:
                    with open(path + '/' + str(datetime.now()).replace(' ', '_') + '.html', 'w') as dump:
                        dump.write(html)

    _logger.info('spamming finished')

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        post_spam('composer_out')
    else:
        post_spam(sys.argv[1])

