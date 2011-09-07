# -*- coding: utf-8 -*-
import os, sys, re, random, cPickle, traceback, urllib, time
from datetime import datetime, timedelta
from functools import partial

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../third_party')

from third_party.BeautifulSoup import BeautifulSoup
from third_party import chardet
from util.log import _logger
from util import pbrowser
from util import util
from third_party.selenium import selenium
from keyword_tree import KeywordElem

from third_party.weibopy import auth as sina_auth
from third_party.weibopy import API as sina_api

class User:
    pass

class Status:
    def __init__(self, text = ''):
        self.text = text

class BrowserSinaWeibo:
    def __init__(self, user=None):
        self.user = user
        self.selenium = selenium('localhost', 4444, 'chrome', 'http://www.baidu.com')
        _logger.info('starting selenium')
        self.selenium.start()
        self.selenium.set_timeout(120 * 1000) # timeout 120 seconds

    def _wait_load(self, minutes = 1):
        MIN = 60 * 1000
        try:
            self.selenium.wait_for_page_to_load(timeout = MIN * minutes)
        except:
            _logger.error('error waiting page to load(%d min), will continue:%s' % (minutes, err))

    def login_sina_weibo(self):
        _logger.debug('logging in to t.cn')
        TEN_MIN = 10 * 60 * 1000
        try:
            _logger.debug('try logging out, just in case')
            self.selenium.click(u'link=退出')
            self._wait_load()
        except Exception, err:
            _logger.debug('clicking loging out link failed')

        # Open sina Weibo
        _logger.debug('opening login page of http://t.sina.com.cn')
        self.selenium.open('http://t.sina.com.cn')
        self._wait_load()
        self.selenium.window_maximize()


        _logger.debug('filling login form')
        try:
            self.selenium.type('id=loginname', self.user.uname)
            self.selenium.type('id=password', self.user.passwd)
            self.selenium.type('id=password_text', self.user.passwd)
            self.selenium.uncheck('id=remusrname')
            self.selenium.click('id=login_submit_btn')
        except Exception, err:
            dumppath = util.dump2file_with_date(self.selenium.get_html_source())
            raise Exception('filling t.cn login form failed: %s, page dumped to %s' % (err, dumppath))
        _logger.debug('logging in')
        self._wait_load()


    def close(self):
        if self.selenium != None:
            self.selenium.stop()

    def user_timeline(self, count = 10):
        # Assume logged in
        self.selenium.click('id=mblog')
        self._wait_load()
        soup = BeautifulSoup(self.selenium.get_html_source())
        tweet = [i.text for i in soup.findAll('p', 'sms')]

        while len(tweet) < count:
            try:
                self.selenium.click(u'下一页')
                self._wait_load()
            except Exception, err:
                _logger.info('failed to load next page: %s', err)
                break
            soup = BeautifulSoup(self.selenium.get_html_source())
            tweet.extend([i.text for i in soup.findAll('p', 'sms')])

        return [Status(i) for i in tweet[:count]]

    def user_timeline_count(self):
        return int(self.selnium.get_text('id=mblog'))

    def _create_user_from_attention_list(li):
        user = User()
        # profile URL
        user.url = li.find('div', 'conBox_l').find('a')['href']
        # nick name
        user.screen_name = user.name = li.find('div', 'conBox_c').find('span', 'class').find('a')['title']
        return user

    def get_all_friend(self, callback=None):
        profile_page = self.selenium.get_location()
        _logger.debug('copy location url: %s' % profile_page)
        _logger.debug('loading attentions page')
        self.selenium.click('id=attentions')
        self._wait_load()

        soup = BeautifulSoup(self.selenium.get_html_source())
        friends = [self._create_user_from_attention_list(i) for i in soup.findAll('li', 'MIB_linedot_l')]
        while True:
            try:
                self.selenium.click(u'下一页')
            except Exception, err:
                _logger.info('failed to load next page: %s' % err)
                soup = BeautifulSoup(self.selenium.get_html_source())
                for li in soup.findAll('li', 'MIB_linedot_l'):
                    friends.append(self._create_user_from_attention_list(li))
                    if callback != None:
                        callback(li)
        return friends
            

    def friends_ids(self):
        pass

    def me(self):
        pass

    # whether a is following b
    def exists_friendship(self, a_id, b_id):
        pass

    # stop following victim
    def destroy_friendship(self, victim_id):
        pass

    def get_user(self, userid):
        pass

    def upload(self, filename, status):
        pass

    def update_status(self, status):
        pass

    def comment(self, id, comment):
        pass

    def create_friendship(screen_name):
        pass

    def followers(self, count = 10):
        pass

    def retweet(self, id):
        pass
        



    
