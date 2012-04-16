# -*- coding: utf-8 -*-
import os, sys, re, random, cPickle, traceback, urllib, time, signal, hashlib, math, commands
from datetime import datetime, timedelta, date
from functools import partial
from BeautifulSoup import BeautifulSoup

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)),  './sdk'))
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), './../')) # Paracode root


from util.log import _logger
from sdk import qqweibo as qq_sdk
from sdk import weibopy as sina_sdk
from api_method import method_dict


def convert_obj(ret_dict, obj):
    class TarasApiResult(object):
        pass
    output = TarasApiResult()
    for key, value in ret_dict.items():
        setattr(output, key, getattr(obj, value))
    return output
        
def adapte_api_method(method_info, api_type):
    native_method = method_info["name"][api_type]
    arg_dict = method_info["arg_convert"][api_type] if ("arg_convert" in method_info and api_type in method_info["arg_convert"]) else {}
    ret_dict = method_info["ret_convert"][api_type] if ("ret_convert" in method_info and api_type in method_info["ret_convert"]) else {}

    def method(adapter, *args, **kwargs):
        arguments = {}
        if len(args) > 0:
            raise Exception("args is not empty, adapted API can't be called using positional arguments")
            
        for key, value in arg_dict.items():
            if key != value:
                kwargs[value] = kwargs[key]
                del kwargs[key]

        ret = native_method(adapter.api, *args, **kwargs)

        if hasattr(ret, '__iter__'): #fixme
            result = list()
            for obj in ret:
                result.append(convert_obj(ret_dict, obj))
            ret = result
        elif type(ret) == bool:
            pass
        else:
            ret = convert_obj(ret_dict, ret)
        
        return ret

    return method


def create_adapted_api(api_type):

    if api_type == "sina":
        _logger.info("creating api from sina sdk")
        sdk_type = sina_sdk

    elif api_type == "qq":
        _logger.info("creating api from qq sdk")
        sdk_type = qq_sdk

    class TarasAPI:
        def __init__(self, api_key, api_secret):
            self.type = api_type
            self.api = None
            self.auth = None
            self._create_auth_adapted(api_key, api_secret)

        def _create_auth_adapted(self, api_key, api_secret):
            self.auth = sdk_type.OAuthHandler(api_key, api_secret)

        def create_api_from_token(self, token):
            self.auth.setToken(token.key, token.secret)
            self.api = sdk_type.API(self.auth)
            return self.api

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
            url = self._get_authorization_url()
            _logger.info("(%s:%s), casperJS is processing authorization URL:%s" % (username, password, url))
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
    for key, value in method_dict.items():
        setattr(TarasAPI, key, adapte_api_method(method_dict[key], api_type))

    return TarasAPI

def test_api(api):
    #print "timeline:" + api.public_timeline()[0].content.encode('utf-8')
    #api.update_status(text="今天星期一，很多事情啊!")
    return api.home_timeline()

#test sina and qq API
def test_sina():
    SinaApi = create_adapted_api("sina")
    api = SinaApi("722861218", "1cfbec16db00cac0a3ad393a3e21f144")
    import sdk.weibopy.oauth
    #token = sdk.weibopy.oauth.OAuthToken('5dcc868e8794b3c2b70e4ca925a158f7','4ac088935496b3290c1be52df71ce97b')
    #api.create_api_from_scratch('sunyayuan610@163.com', 'f_rank610')
    #api.api = api.create_api_from_token(token)
    #api = api.create_api_from_token(token)
    #print api.api.me()
    print api._get_authorization_url()
    pin = raw_input("Enter the pin:")
    token = api.auth.get_access_token(pin)
    print token 
    api.api = api.create_api_from_token(token)
    return api.comment(id='3429965100251372', text='好美啊')

def test_qq():
    QQApi = create_adapted_api("qq")
    api = QQApi("801098027", "af8f3766d52c544852129d7952fd5089")
    api.create_api_from_scratch("2603698377", "youhao2006")
    #print api.is_user_following_me(user_name="minitalks")
    #return api.api._user_update_head(filename="/var/www/ipshow/res/index_background.jpg")
    return api.retweet(id="118099061141747", text='')

if __name__ == "__main__":
    _logger.info("debugging api_adapter.py")
    QQApi = create_adapted_api("qq")
    SinaApi = create_adapted_api("sina")

    # Testing QQ api
    api = QQApi("801098027", "af8f3766d52c544852129d7952fd5089")
    api.create_api_from_scratch("2603698377", "youhao2006")
    print api.me()

    
    # Testing Sina api
    api = SinaApi("722861218", "1cfbec16db00cac0a3ad393a3e21f144")
    #print api._get_authorization_url()
    #pin = raw_input("Enter the pin:")
    #token = api.auth.get_access_token(pin)
    #print token
    import sdk.weibopy.oauth
    token = sdk.weibopy.oauth.OAuthToken('fa473fbdc1d8b736e18a72f2ccad07d3','baac261ce0698aef8cfb5b35bdd79b7a')
    #api.api = api.create_api_from_token(token)
    #api.create_api_from_scratch("diyidawang@163.com", "wjb0371")
    api.api = api.create_api_from_token(token)
    print api.api.me()
    #test_api(api)

    # Testing QQ api
    api = QQApi("801098027", "af8f3766d52c544852129d7952fd5089")
    api.create_api_from_scratch("2603698377", "youhao2006")
    print api.api.me()
