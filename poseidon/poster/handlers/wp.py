#! /usr/bin/python
# -*- coding: utf-8 -*-

import sys, os
from os.path import abspath, dirname, sep

current_dirname = dirname(abspath(__file__)) + sep
sys.path.append(abspath(current_dirname + '../../'))

from util.log import _logger

class wp_handler:

    _wp_config = {
        'login': {
            'form_name': 'loginform',
            'form_username': 'log',
            'form_password': 'pwd',
            'challenge_test': lambda html: html != None and 'Dashboard' in html,
        },
        'post': {
            'form_name': 'post',
            'form_title': 'post_title',
            'form_content': 'content',
            'form_additional_data': {
            },
            'content_style': 'html', #or bbcode
            'challenge_test': lambda html: html != None and 'Post published.' in html,
        },
        'sleep': { #int or float in seconds, function 'time.sleep' is used
            'index': 1,
            'login': 1,
            'after_login': 1,
            'blog_login': 1,
            'after_blog_login': 1,
            'post': 1,
        },
    }

    _wp_base_url = ''


    def __init__(self):
        self._status_login = False

    def _login(self, browser, login_config):
        #pre-login
        fail = 0
        while fail < 5:
            try:
                browser.open(login_config['login_url'])
                break
            except Exception, err:
                _logger.error('open login page failed (%d/5)' % (fail + 1))
                fail += 1
        if fail == 5:
            return False
        #check code

        #post-login
        try:
            if login_config['form_name'] != None:
                browser.select_form(login_config['form_name'])
            else:
                browser.select_form(nr = login_config['form_index'])
            browser[login_config['form_username']] = login_config['username']
            browser[login_config['form_password']] = login_config['password']
        except Exception, err:
            _logger.error("Failed to fill login form: %s" % err)
            return False

        self._sleep('login')
        retry = 0
        login_resp_html = ""
        while retry < 3:
            try:
                req = browser.click()
                login_response = browser.open(req)
                login_resp_html = login_response.read()
                break
            except Exception, err:
                retry += 1
                _logger.error("login form sumbition failed (%d/3)" % retry)
        if retry == 3:
            _logger.error("login form submition failed permanantly")
            
        #check code
        test = login_config['challenge_test'](login_resp_html)
        if not test:
            _logger.error("failed validation test")
        return test

    def _post_article(self, browser, post_config):
        fail = 0
        while fail < 5:
            try:
                browser.open("post-new.php", timeout=10)
                break
            except Exception, err:
                _logger.error('open submit url:(post-new.php) failed %d / 5' % (fail + 1))
                fail += 1

        if fail == 5:
            _logger.error('open submit url(post-new.php) failed permanently')
            return False, "can't open submit url(post-new.php)"

        # Don't catch the exception since such errors may be resulted from Wordpress template changing
        try:
            browser.select_form(post_config['form_name'])
            browser[post_config['form_title']] = post_config['title']
            browser[post_config['form_content']] = post_config['content']
        except Exception, err:
            _logger.error('sumbit form filling failed:%s' % err)
            return False, 'sumbit form filling failed:%s' % err

        fail = 0
        post_resp = None
        post_result = ''
        while fail < 5:
            try:
                req = browser.click(name="publish")
            except Exception, err:
                _logger.error('failed to find submit button:%s' % err)
                break
            try:
                post_resp = browser.open(req, timeout=10)
                post_result = post_resp.read()
                break
            except Exception, err:
                _logger.error('submit failed(url:%s) for %d / 5: %s' % (req.get_full_url(), fail + 1, err))
                fail += 1

        if not post_config['challenge_test'](post_result):
            _logger.error('posting didn\'t pass challenge test, probably failed')
            return False, post_result
        return True, post_result

    def _sleep(self, name):
        from time import sleep
        if name in self._wp_config['sleep']:
            _logger.debug('sleep %d seconds for %s' % (self._wp_config['sleep'][name],name))
            sleep(self._wp_config['sleep'][name])
        else:
            _logger.debug('sleep 0.5 seconds for ' + name)
            sleep(0.5)

    def post_blog(self, browser, post_config):
        self._wp_base_url = post_config['base-url']
        self._wp_config['login']['username'] = post_config['username']
        self._wp_config['login']['password'] = post_config['password']
        self._wp_config['login']['login_url'] = self._wp_base_url + 'wp-login.php'
        if not self._login(browser, self._wp_config['login']):
            _logger.error('login failed (%s:%s), url:(%s)' % (post_config['username'], post_config['password'], self._wp_config['login']['login_url']))
            return False, ''

        self._sleep('after_login')

        self._wp_config['post']['title'] = post_config['title']
        self._wp_config['post']['content'] = post_config['content']
        return self._post_article(browser, self._wp_config['post'])

if __name__ == "__main__":
    print "not for execution";
