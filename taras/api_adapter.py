# -*- coding: utf-8 -*-
import os, sys, re, random, cPickle, traceback, urllib, time, signal, hashlib, math, commands
from datetime import datetime, timedelta, date
from functools import partial
from BeautifulSoup import BeautifulSoup

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../taras/sdk')

from util.log import _logger
from sdk import qqweibo as qq_sdk
from sdk import weibopy as sina_sdk

method_dict = {'public_timeline':
                   {"name": {"sina": sina_sdk.API.public_timeline,
                             "qq": qq_sdk.API._statuses_public_timeline},
                    "arg_convert": {},
                    "ret_convert": {"sina": {"text": "text"},
                                    "qq": {"text": "text"},}
                   },

                'home_timeline':
                    {"name": {"sina": sina_sdk.API.friends_timeline,
                              "qq": qq_sdk.API._statuses_home_timeline}, 
                     "arg_convert": {}, 
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}},
                    },

                'user_timeline':
                    {"name": {"sina": sina_sdk.API.user_timeline,
                              "qq": qq_sdk.API._statuses_user_timeline},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}}
                    },
                

                'update_status':
                   {"name": {"sina": sina_sdk.API.update_status,
                             "qq": qq_sdk.API._t_add},
                    "arg_convert": {"sina": {"text": "status"},
                                    "qq": {'text': "content"}},
                    "ret_convert": {"sina": {"message": "text"},
                                    "qq": {"message": "id"}}
                   },

                'comment':
                    {"name": {"sina": sina_sdk.API.comment,
                              "qq": qq_sdk.API._t_comment},
                     "arg_convert": {"sina": {"id": "id",
                                              "text": "comment",
                                              "cid": "cid"},
                                     "qq": {"id": "reid",
                                            "text": "content"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                    },

                'get_status':
                    {"name": {"sina": sina_sdk.API.get_status,
                              "qq": qq_sdk.API._t_show},
                     "arg_convert": {"sina": {"id": "id"},
                                     "qq": {"id": "id"}},
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}}
                    },

                'post_image_text':
                    {"name": {"sina": sina_sdk.API.upload,
                              "qq": qq_sdk.API._t_add_pic},
                     "arg_convert": {"sina": {"text": "status",
                                              "image": "filename"},
                                     "qq": {"text": "content",
                                            "image": "filename"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                    },

                'retweet':
                    {"name": {"sina": sina_sdk.API.repost,
                              "qq": qq_sdk.API._t_re_add},
                     "arg_convert": {"sina": {"id": "id",
                                              "text": "status"},
                                     "qq": {"id": "reid",
                                            "text": "content"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                     },

                'get_user':
                    {"name": {"sina": sina_sdk.API.get_user,
                              "qq": qq_sdk.API._user_other_info},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"screen_name": "screen_name"},
                                     "qq": {"screen_name": "name"}}
                    },

                'search_users':
                    {"name": {"sina": sina_sdk.API.search_users,
                              "qq": qq_sdk.API._search_user},
                     "arg_convert": {"sina": {"keyword": "q"},
                                     "qq": {"keyword": "keyword"}},
                     "ret_convert": {"sina": {"screen_name": "name"},
                                     "qq": {"screen_name": "name"}}
                    },
                    
                'following':
                    {"name": {"sina": sina_sdk.API.friends,
                              "qq": qq_sdk.API._friends_user_idollist},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"screen_name": "name"},
                                     "qq": {"screen_name": "name"}}
                     },
                
                'follower':
                    {"name": {"sina": sina_sdk.API.followers,
                              "qq": qq_sdk.API._friends_user_fanslist},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"screen_name": "name"},
                                     "qq": {"screen_name": "name"}}
                    },

                'follow':
                    {"name": {"sina": sina_sdk.API.create_friendship,
                              "qq": qq_sdk.API._friends_add},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },
                
                'unfollow':
                    {"name": {"sina": sina_sdk.API.destroy_friendship,
                              "qq": qq_sdk.API._friends_del},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },

                'is_user_following_me':
                    {"name": {"sina": sina_sdk.API.exists_friendship,
                              "qq": qq_sdk.API.is_user_following_me},
                     "arg_convert": {"sina": {"user_uid": "user_a",
                                              "my_uid": "user_b"},
                                     "qq": {"user_uid": "user"}},
                     "ret_convert": {"sina": {"friends": "friends"},
                                     "qq": {}}
                    },
                    
                'is_following_user':
                    {"name": {"sina": sina_sdk.API.exists_friendship,
                              "qq": qq_sdk.API.is_following_user},
                     "arg_convert": {"sina": {"user_uid": "user_b",
                                              "my_uid": "user_a"},
                                     "qq": {"user_uid": "user"}},
                     "ret_convert": {"sina": {"friends": "friends"},
                                     "qq": {}}
                    },

                'update_profile':
                    {"name": {"sina": sina_sdk.API.update_profile,
                              "qq": qq_sdk.API._user_update},
                     "arg_convert": {"sina": {"screen_name": "name",
                                              "description": "description"},
                                     "qq": {"screen_name": "nick",
                                            "description": "introduction"}},
                    "ret_convert": {"sina": {"message": "screen_name"},
                                    "qq": {"message": "msg"}}
                    },

                'update_profile_image': 
                    {"name": {"sina": sina_sdk.API.update_profile_image,
                              "qq": qq_sdk.API._user_update_head},
                     "arg_convert": {"sina": {"image": "filename"},
                                     "qq": {"image": "filename"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },

                'me':
                    {"name": {"sina": sina_sdk.API.me,
                              "qq": qq_sdk.API.me},
                    "arg_convert": {},
                    "ret_convert": {"sina": {"message": "screen_name"},
                                    "qq": {"message": "msg"}}
                    }
               }

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
            return sdk_type.API(self.auth)

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
    return api.get_user(uid='2119096435')

def test_qq():
    QQApi = create_adapted_api("qq")
    api = QQApi("801098027", "af8f3766d52c544852129d7952fd5089")
    api.create_api_from_scratch("2603698377", "youhao2006")
    #print api.is_user_following_me(user_name="minitalks")
    #return api.api._user_update_head(filename="/var/www/ipshow/res/index_background.jpg")
    return api.retweet(id="118099061141747", text='')

if __name__ == "__main__":
    _logger.info("debugging api_adapter.py")
    test_sina()
    sys.exit(0)

    QQApi = create_adapted_api("qq")
    SinaApi = create_adapted_api("sina")
    
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
    test_api(api)
