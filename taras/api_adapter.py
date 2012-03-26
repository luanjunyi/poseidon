# -*- coding: utf-8 -*-
import os, sys, re, random, cPickle, traceback, urllib, time, signal, hashlib, math, commands
from datetime import datetime, timedelta, date
from functools import partial
from BeautifulSoup import BeautifulSoup

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../taras/sdk')

from util.log import _logger
from util import pbrowser
from sdk import qqweibo as qq_sdk
from sdk import weibopy as sina_sdk

class TarasAPI:
    def __init__(self, api_type, api_key, api_secret):
        self.type = api_type
        self.api = None
        self.auth = None

        if self.type == "sina":
            _logger.info("creating api from sina sdk")

        elif self.type == "qq":
            _logger.info("creating api from qq sdk")

        self._create_auth_adpated(api_key, api_secret)

    def _create_auth_adpated(self, api_key, api_secret):
        if self.auth == None and self.type == "sina":
            self.auth = sina_sdk.OAuthHandler(api_key, api_secret)
        elif self.auth == None and self.type == "qq":
            self.auth = qq_sdk.OAuthHandler(api_key, api_secret)

    def _get_authorization_url_adapted(self):
        return self.auth.get_authorization_url()

    def _parse_verify_code(self, raw):
        for line in raw.split('\n'):
            if line.startswith("code:"):
                return line[len("code:"):]
        _logger.error("failed to parse verification code, raw output is {%s}" % raw)
        return ""
        

    def create_token_from_web(self, username, password):
        casper_path = os.path.dirname(os.path.abspath(__file__)) + "/verify_weibo.js"
        br = pbrowser.get_browser()
        url = self._get_authorization_url_adapted()
        _logger.info("casperJS is processing authorization URL:" + url)
        casper_cmd = "casperjs %s '%s' --user='%s' --passwd='%s' --type=%s " % (casper_path, url, username, password, self.type)
        casper_out = commands.getoutput(casper_cmd)
        #_logger.debug("casperjs output:{%s}" % casper_out)
        verify_code = self._parse_verify_code(casper_out)
        _logger.debug("got verify code:(%s)" % verify_code)
    
        token = self.auth.get_access_token(verify_code)
        return token

    def create_api_from_token_adapted(self, token):
        self.auth.setToken(token.key, token.secret)
        if self.type == "sina":
            api = sina_sdk.API(self.auth)
        elif self.type == "qq":
            api = qq_sdk.API(self.auth)
        return api

    def create_api_from_scratch(self, username, password):
        token = self.create_token_from_web(username, password)
        self.api = self.create_api_from_token_adapted(token)

def test_api(api):
    me = api.api.me()

    if hasattr(me, 'screen_name'):
        print me.screen_name
    else:
        print me.nick

if __name__ == "__main__":
    _logger.info("debugging api_adapter.py")
    # Testing QQ api
    api = TarasAPI("qq", "801098027", "af8f3766d52c544852129d7952fd5089")
    api.create_api_from_scratch("2603698377", "youhao2006")
    test_api(api)
    
    # Testing Sina api
    api = TarasAPI("sina", "722861218", "1cfbec16db00cac0a3ad393a3e21f144")
    api.create_api_from_scratch("luanjunyi@gmail.com", "admin123")
    test_api(api)
    
