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

def adapte_api_method(adapter, method_dict):
    if not adapter.type in method_dict:
        _logger.error("failed to find type(%s) in method_dict" % adapter.type)
        return None

    native_method = method_dict[adapter.type]
    api = adapter.api

    def method(adapter, *args, **kwargs):
        native_method(adapter.api, *args, **kwargs)

    return method

def create_adapted_api(api_type):
    if api_type == "sina":
        _logger.info("creating api from sina sdk")

    elif api_type == "qq":
        _logger.info("creating api from qq sdk")


    def _create_auth_adapted():
        if api_type == "sina":
            auth_type = sina_sdk.OAuthHandler
        elif api_type == "qq":
            auth_type = qq_sdk.OAuthHandler

        def method(adapter, api_key, api_secret):
            adapter.auth = auth_type(api_key, api_secret)
        return method

    def create_api_from_token_adapted():
        if api_type == "sina":
            api_class = sina_sdk.API
        elif api_type == "qq":
            api_class = qq_sdk.API

        def method(adapter, token):
            adapter.auth.setToken(token.key, token.secret)
            return api_class(adapter.auth)

        return method
        

    class TarasAPI:
        def __init__(self, api_key, api_secret):
            self.type = api_type
            self.api = None
            self.auth = None
            self._create_auth(api_key, api_secret)

        _create_auth = _create_auth_adapted()
        create_api_from_token = create_api_from_token_adapted()


        def _get_authorization_url(self):
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
            url = self._get_authorization_url()
            _logger.info("casperJS is processing authorization URL:" + url)
            casper_cmd = "casperjs %s '%s' --user='%s' --passwd='%s' --type=%s " % (casper_path, url, username, password, self.type)
            casper_out = commands.getoutput(casper_cmd)
            #_logger.debug("casperjs output:{%s}" % casper_out)
            verify_code = self._parse_verify_code(casper_out)
            _logger.debug("got verify code:(%s)" % verify_code)

            token = self.auth.get_access_token(verify_code)
            return token

        def create_api_from_scratch(self, username, password):
            token = self.create_token_from_web(username, password)
            self.api = self.create_api_from_token(token)

        # API bindings
        public_timeline = adapte_api_method({'sina': self.api.public_timeline,
                                             'qq': self.api._statuses_public_timeline})


    return TarasAPI


def test_api(api):
    me = api.api.me()

    if hasattr(me, 'screen_name'):
        print api.public_timeline()[0]
    else:
        print me.nick

if __name__ == "__main__":
    _logger.info("debugging api_adapter.py")
    QQApi = create_adapted_api("qq")
    SinaApi = create_adapted_api("sina")
    # Testing QQ api
    api = QQApi("801098027", "af8f3766d52c544852129d7952fd5089")
    api.create_api_from_scratch("2603698377", "youhao2006")
    test_api(api)
    
    # Testing Sina api
    api = SinaApi("722861218", "1cfbec16db00cac0a3ad393a3e21f144")
    api.create_api_from_scratch("luanjunyi@gmail.com", "admin123")
    test_api(api)
    
