#! /usr/bin/python
# -*- coding: utf-8 -*-
#this file work with iBoker v1.0.0

__author__="johnx"
__date__ ="$Mar 29, 2011 1:56:48 PM$"
__version__ = '0.3.4'

class dvbbs_handler:

    _ndocr_dll = None
    _dv_config = {
        'login': {
            'form_name': None,
            'form_index': 0,
            'form_username': 'username',
            'form_password': 'password',
            'challenge_test': lambda html: html != None and u'登录成功'.encode('gbk') in html,
        },
        'blog': {
            'form_name': 'apply',
            'form_vcode': 'codestr',
            'form_password': 'PassWord',
            'challenge_test': lambda html: html != None and u'欢迎进入您的博客管理'.encode('gbk') in html and u'验证码校验失败'.encode('gbk') not in html,
        },
        'post': {
            'form_name': 'PostForm',
            'form_title': 'Title',
            'form_content': 'PostContent',
            'form_additional_data': {
#               for example only
#                'cat_id': 1,
#                'sub_cat_id': 2,
#                'sub_type_id': 2,
            },
            'content_style': 'html', #or bbcode
        },
        'scripts': {
            'index': 'index.asp',
            'login': 'login.asp',
            'blog_login': 'BokeManage.asp',
            'vcode': 'DV_getcode.asp',
            'post': 'BokeManage.asp?s=1&t=1&m=1',
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

    _dv_base_url = ''

    #sample
    _dv_post_config = {
        'username': 'wulaishiwo',
        'password': 'wenjin1006',
        'base_url': 'http://some.url',
        'title': '',
        'content': '',
        'login': True,
        'blog_login': True,
    }

    def __init__(self):
        if self.__class__._ndocr_dll == None:
            self._load_ndocrs()

    def _load_ndocrs(self):
        import ctypes
        self.__class__._ndocr_dll = ctypes.windll.LoadLibrary( 'c:\\ndocr.dll' )
        self._ndocr_dll = self.__class__._ndocr_dll

        #loads trainning library
        self._ndocr_dll.loadLib('c:\\ndocr1.dll', 'normal', 'c:\\20.lib','')

    def _analytics_code(self, url, browser):
        """returns a string
        """
        import ctypes, os
        filename, resp = browser.retrieve(url)
        result = ctypes.c_char_p(self._ndocr_dll.getCodeFromFile(filename, '', 'normal', '20')).value
        os.remove( filename )
        return result

    def _login(self, browser, login_config):
        #pre-login
        browser.open(login_config['login_url'])
        #check code

        #post-login
        if login_config['form_name'] != None:
            browser.select_form(login_config['form_name'])
        else:
            browser.select_form(nr = login_config['form_index'])

        browser[login_config['form_username']] = login_config['username']
        browser[login_config['form_password']] = login_config['password']

#        print browser.form

        self._sleep('login')
        login_response = browser.submit()
        login_resp_html = login_response.read()
#        print login_resp_html
        #check code
        return login_config['challenge_test'](login_resp_html)


    def _blog_login(self, browser, blog_config):

        blog_login_resp_html = ''
        retries = 0
        while not blog_config['challenge_test'](blog_login_resp_html) and retries < 11:
            #pre-login-2
            #check code
            try:
                browser.open(blog_config['login_url'])
                browser.select_form(blog_config['form_name'])
                browser[blog_config['form_password']] = blog_config['password']
                browser[blog_config['form_vcode']] = self._analytics_code( self._script_url('vcode'), browser )
                
                self._sleep('blog_login')
                blog_login_resp = browser.submit()
                blog_login_resp_html = blog_login_resp.read()
                #check code
            except Exception, err:
                print repr(err), blog_config, 'retries: ', retries
#                exit()
#                print blog_login_resp_html
                if retries < 10:
                    retries += 1
                else:
                    return False

#        print blog_login_resp_html
        return True

    def _post_article(self, browser, post_config):

        import re, random, mechanize

        pre_post_resp = browser.open(post_config['post_url'])
        browser.select_form(post_config['form_name'])
        browser[post_config['form_title']] = post_config['title']
        browser[post_config['form_content']] = post_config['content']

        if 'cat_id' in post_config['form_additional_data']:
            cat_id = str(post_config['form_additional_data']['cat_id'])
        else:
            #fill form
            pattern = re.compile('BokeCat_ID\[0\]=\[(.*)\]')
            matchs = pattern.search( pre_post_resp.read() )
            cat_ids = [str(id) for id in eval( matchs.groups()[0])]
            cat_id = random.choice( cat_ids )

        #create control for select cat_id
        cat_item = mechanize.Item( browser.form.find_control('Catid'), { 'value': cat_id } )
        browser['Catid'] = [cat_id]
    #    print cat_ids
    #    print form.find_control('Catid')

        if 'sub_cat_id' in post_config['form_additional_data']:
            browser['sCatID'] = [str(post_config['form_additional_data']['sub_cat_id'])]
        else:
            #choice for sCatID
            items = browser.form.find_control('sCatID').get_items()
            values = [ item.attrs['value'] for item in items ]

            if -1 in values:
                values.remove( -1 )

            #print values
            browser['sCatID'] = [ random.choice( values ) ]

        if 'sub_type_id' in post_config['form_additional_data']:
            browser['sType'] = [str(post_config['form_additional_data']['sub_type_id'])]
        else:
            browser['sType'] = ['0']
            

        self._sleep('post')
        post_resp = browser.submit()
#        print post_resp.read()
        return post_resp.code == 200

    def _update_config(self, config):
        for key in self._dv_config:
            if key in config:
                self._dv_config[key].update(config[key])

    def _script_url(self, name):
        if name in self._dv_config['scripts']:
            return self._dv_base_url + self._dv_config['scripts'][name]
        else:
            return self._dv_base_url

    def _sleep(self, name):
        from time import sleep
        if name in self._dv_config['sleep']:
            print 'sleep', self._dv_config['sleep'][name], 'seconds for', name
            sleep(self._dv_config['sleep'][name])
        else:
            print 'sleep 0.5 seconds for ', name
            sleep(0.5)

    def post_blog(self, browser, post_config = {}, config = {}):

        #update configs
        self._update_config(config)
        self._dv_base_url = post_config['base_url']

        #open index
        browser.open(self._script_url('index'))
        self._sleep('index')
        #check code

        if 'login' not in post_config or post_config['login']:
            _login_conf = self._dv_config['login']
            _login_conf['username'] = post_config['username']
            _login_conf['password'] = post_config['password']
            _login_conf['login_url'] = self._script_url('login')
            self._status_login = self._login(browser, _login_conf)
            print 'login ' + str(self._status_login)

        if not self._status_login:
            raise Exception('login failed')
        
        self._sleep('after_login')

        if 'blog_login' not in post_config or post_config['blog_login']:
            self._dv_config['blog']['password'] = post_config['password']
            self._dv_config['blog']['login_url'] = self._script_url('blog_login')
            self._status_blog_login = self._blog_login( browser, self._dv_config['blog'] )
            print 'blog login ' + str(self._status_blog_login)

        if not self._status_blog_login:
            raise Exception('blog login failed')

        self._sleep('after_blog_login')

        self._dv_config['post']['title'] = post_config['title']
        self._dv_config['post']['content'] = post_config['content']
        self._dv_config['post']['post_url'] = self._script_url('post')
        return self._post_article( browser, self._dv_config['post'] )

if __name__ == "__main__":
    print "not for execution";
