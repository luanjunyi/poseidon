# -*- coding: utf-8 -*-

import os, sys, re, random, cPickle, traceback, urllib2, threading
from functools import partial
from urlparse import urlparse

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../../') # Paracode root

from third_party.BeautifulSoup import BeautifulSoup
from util import pbrowser
from third_party.xoltar import threadpool as xthreading

from util.log import _logger
from poseidon.interpreter.interpreter import parse_html

doc_sep = '=' * 100
paragraph_sep = '+' * 100

def load_class_by_name(class_path):
    package = '.'.join(class_path.split('.')[:-1])
    class_name = class_path.split('.')[-1]
    module = __import__(package, {}, {}, [class_name])
    return getattr(module, class_name)

class BlogCommenter:
    _post_queue = list()

    def __init__(self, thread=3):
        self._success_count = 0
        self._attempt_count = 0

        # Load comments
        with open('blog-comments') as comm:
            self.comment_seg = filter(lambda c: len(c) > 5, map(str.strip, comm.read().split('#')))
        if len(self.comment_seg) < 5:
            _logger.error('%d comments found, too small' % len(self.comment_seg))
        self.thread_pool = xthreading.ThreadPool(maxThreads = thread)


    def get_success_rate(self):
        return self._success_count, self._attempt_count, 0 if self._attempt_count == 0 else "%.2f" % (float(self._success_count) / float(self._attempt_count))

    def _is_valid_paragraph(self, text):
        return text.find(',') != -1 and text.find('.') != -1 and len(text) >= 50

    def compose_comment(self, blog):
        random.seed()
        comment = random.choice(self.comment_seg)
        blog.comment = comment.encode('utf-8')

    def _parse_control_for_name(self, control, target_name, blog):
        if control.has_key(target_name):
            blog.post_data[target_name] = target_name
        elif control.has_key('id') and control['id'] == target_name and control.has_key('name'):
            blog.post_data[target_name] = control['name']

    def parse_blog_meta(self, rawblog, blog):
        soup = BeautifulSoup(rawblog)
        # Find the comment submit form
        keytext = soup.findAll(text=lambda t: re.search(self.cur_fingerprint.decode('utf-8'), t, re.IGNORECASE) != None)
        if len(keytext) < 1:
            _logger.error('got 0 fingerprint(%s) for posting blog comments, I\'ll ignore this one' % self.cur_fingerprint)
            return False
        form = keytext[0].findParents('form')
        if len(form) != 1:
            _logger.error('got %d form for posting blog comments, I\'ll ignore this one' % len(form))
            return False
        form = form[0]
        # Get the 'action' field from comment form
        if not form.has_key('action') or form['action'] == '':
            _logger.error('the comment form\'s action attribute doesn\'t exist or is empty, ignore this one')
            return False
        blog.submit_url = form['action']
        # Fill various fields in the comment form
        # Check necessary fields are provided
        # There are four fields: url, comment, email and author.
        # WordPress has them named 'url', 'comment', 'email' and 'author',
        # Another template(maybe also WordPress), use the above four string as ID attributes, and
        # set the 'name' attribute to some random string
        for field in form.findAll(['input', 'textarea']):
            self._parse_control_for_name(field, 'author', blog)
            self._parse_control_for_name(field, 'email', blog)
            self._parse_control_for_name(field, 'comment', blog)
            self._parse_control_for_name(field, 'url', blog)

        # If one of the four fields is missing, consider it an error
        if not blog.post_data.has_key('author'):
            _logger.error('comment form has no "author" field, ignore')
            return False
        if not blog.post_data.has_key('comment'):
            _logger.error('comment form has no "comment" field, ignore')
            return False
        if not blog.post_data.has_key('email'):
            _logger.error('comment form has no "email" field, ignore')
            return False
        if not blog.post_data.has_key('url'):
            _logger.error('comment form has no "url" field, ignore')
            return False

        return True

    def read_one_blog(self, rawblog):
        blog = _BlogPost()
        blog.url = rawblog['url']
        blog.paragraphs = filter(self._is_valid_paragraph, parse_html(rawblog))
        if self.parse_blog_meta(rawblog['content'], blog) != True:
            _logger.error('parse blog meta failed, url:%s' % blog.url)
            return None
        #print ('\n\n' + paragraph_sep + '\n\n') .join(blog.contents).encode('utf-8')
        #print '\n\n' + doc_sep + '\n\n'
        return blog

    def _fill_comment_form(self, browser, blog, anchor, href):
        browser.select_form(predicate=lambda form: dict(form.attrs).has_key('action') and dict(form.attrs)['action'] == blog.submit_url)
        browser.form[blog.post_data['email']] = 'wulaishiwo@gmail.com'
        browser.form[blog.post_data['author']] = anchor
        browser.form[blog.post_data['url']] = href
        browser.form[blog.post_data['comment']] = blog.comment

    def spam_one_blog(self, anchor, href, target_url):
        if target_url.find('/interstitial?url=') != -1:
            _logger.debug('stripped %s to %s' % (target_url, target_url[len('/interstitial?url='):]))
            target_url = target_url[len('/interstitial?url='):]
        error = ''
        retry = 0
        # Open blog post page
        browser = pbrowser.get_browser()
        while retry < 5:
            try:
                res = browser.open(target_url, timeout=10)
                html = res.read()
                break
            except Exception, err:
                error += 'open blog url failed (%d / 5):%s\n' % (retry + 1, err)
                retry += 1
        if retry == 5:
            _logger.error('failed spamming: %s', target_url)
            return False, [target_url, error]
        error += 'open scceeded anyway\n'
        # Parse blog
        raw_blog = {}
        raw_blog['content'] = html
        raw_blog['url'] = target_url

        blog = self.read_one_blog(raw_blog)

        if blog == None:
            _logger.error('failed spamming: %s', target_url)
            return False, [target_url, error + 'failed to parse blog content\n']
        # Fill comments, url, author, email
        self.compose_comment(blog)
        try:
            self._fill_comment_form(browser, blog, anchor, href)
        except Exception, err:
            error += 'Can\'t process sumbit form for url:%s\n%sform:%s\nblog:%s' % (target_url, traceback.format_exc(), browser.form, blog.post_data)
            _logger.error('failed spamming: %s', target_url)
            return False, [target_url, error]

        # Submit comment
        retry = 0
        while retry < 5:
            try:
                html = browser.open(browser.form.click(), timeout=10).read()
                break
            except urllib2.HTTPError, err:
                error += 'submmint comment with URLError, I see this as fatal'
                error += err.read()
                retry = 5
                
            except Exception, err:
                error += 'submmint comment failed (%d / 5):%s\n' % (retry + 1, err)
                retry += 1
        
        if retry == 5:
            _logger.error('failed spamming: %s', target_url)
            return False, [target_url, error]

        _logger.info('spammed: %s', target_url)
        return True, [target_url, html]

    def process_new_url(self, url, anchor, href):
        return self.thread_pool.put(partial(self.spam_one_blog, anchor=anchor, href=href, target_url = url), block=False)

    def start_spam(self, anchor, href, keyword, count = 100, verbose = False, fingerprint = "will not be published"):
        """
        Start spamming, use keyword to query Google, request for 'count' results. Anchor text and url are specified with
        'anchor' and 'href'.
        """
        # Make diretory:
        path = "./%s(%s).%d/" % (anchor, keyword, count)
        if verbose:
            if os.path.exists(path):
                _logger.error('%s exists, I\'ll have to remove it, sorry' % path)
                import shutil
                shutil.rmtree(path)
            os.mkdir(path)


        query = keyword + " " + fingerprint
        self.cur_fingerprint = fingerprint[1:-1]
        lazy_result = []
        urls = pbrowser.ask_google(query, count,
                                   callback=lambda new_url: lazy_result.append(self.process_new_url(new_url, anchor, href)),
                                   sleep_min = 15,
                                   sleep_max = 20,
                                   )
        _logger.info('ask_google retured %d results, start joinning %s target' % (len(urls), len(lazy_result)))
        success_count = 0
        for result in lazy_result:
            try:
                success, info = result.eval()
            except Exception, err:
                _logger.error("failed extracting lazy result:%s" % (err))
            else:
                try:
                    output_path = path + (urlparse(info[0]).hostname + str(random.randint(1,1000)))
                except:
                    _logger.error("can't parse hostname from target url:[%s]" % info[0])
                    output_path = path + "info[0]" + str(random.randint(1,1000))
            if success:
                success_count += 1
                output_path += '.success.html'
            else:
                output_path += '.fail.html'
            if verbose:
                with open(output_path.encode('utf-8'), 'w') as output:
                    output.write(info[0] + '\n')
                    output.write(info[1])
        self._success_count += success_count
        self._attempt_count += len(lazy_result)
        _logger.info('%d/%d succeeded' % (self._success_count, self._attempt_count))

class _BlogPost:
    def __init__(self):
        self.comment = ''
        self.paragraphs = None
        self.url = None
        self.submit_url = ''
        self.post_data = {} # A dict containing all parameters to post

def usage():
    print 'Usage: blog_zealot.py -k KEYWORD -r URL -a ANCHOR -f FINGERPRINT [-c NUMBER-NEEDED=1000] [-t THREAD-NUMBER=3] [-v]'

def _leave(time):
    _logger.critical("Killing main thread after %s seconds" % time)
    sys.exit(1)

if __name__ == '__main__':
    threading.Timer(4000, _leave, [4000]).start()

    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'f:a:k:r:c:t:l:v', ['fingerprint=', 'anchor=', 'keyword=', 'href=', 'count=', 'thread=', 'keyword-list='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()
        sys.exit(2)

    keyword = ''
    anchor = ''
    count = 1000
    thread = 3
    keyword_list = ''
    url = ''
    fp = ''
    verbose = False
    for opt, arg in opts:
        if opt in ('-a', '--anchor'):
            anchor = arg
        if opt in ('-k', '--keyword'):
            keyword = arg
        if opt in ('-r', '--href'):
            url = arg
        if opt in ('-c', '--count'):
            count = int(arg)
        if opt in ('-t', '--thread'):
            thread = int(arg)
        if opt in ('-f', '--fingerprint'):
            fp = arg
        if opt in ('-v'):
            verbose = True

    if keyword == '' or url == '' or anchor == '' or fp == '':
        print "none of them should be empty, keyword:%s, url:%s, anchor:%s, fp:%s" % (keyword, url, anchor, fp)
        usage()
    else:
        bc = BlogCommenter(thread)
        _logger.info('starting spam, anchor: (%s) keyword: (%s), url:%s, count:%d, thread:%d, fingerprint:(%s)'
                     % (anchor, keyword, url, count, thread, fp))
        bc.start_spam(anchor, url, keyword, count, verbose, fingerprint=fp)
        _logger.info('success rate:%s' % str(bc.get_success_rate()))
        _logger.info('spamming finished, good luck!')

