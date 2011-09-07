# -*- coding: utf-8 -*-

import os, sys
from xml.etree import ElementTree
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
from util.log import _logger


class UserAccount:
    def __init__(self):
        self.uname = ""
        self.passwd = ""
        self.tags = []

class AppAccount:
    def __init__(self):
        self.id = ""
        self.consumer_key = ""
        self.consumer_secret = ""

def load_config(filename):
    return _parse_config(ElementTree.parse(filename))

def _parse_config(et):
    # In case of exceptions, crash. Who wants to proceed with ill-config?

    # Parse user accounts
    user_accounts = []
    users = et.findall('user-accounts')
    if users == None or len(users) > 1:
        _logger.error("find zero or more-than-one user-account in the configuration file, will fail")
        raise Exception("find zero or more-than-one user-account in the configuration file")
    users = users[0].findall('account')
    for user in users:
        ua = UserAccount()
        ua.uname = user.find('user-name').text
        ua.passwd = user.find('password').text
        ua.tags = [t.text for t in user.findall('tag')]
        user_accounts.append(ua)

    # Parse app accounts
    app_accounts = []
    apps = et.findall('app-accounts')
    if apps == None or len(apps) > 1:
        _logger.error("find zero or more-than-one app-accounts in the configuration file, will fail")
        raise Exception("find zero or more-than-one app-accounts in the configuration file")
    apps = apps[0].findall('account')
    for app in apps:
        aa = AppAccount()
        aa.id = app.attrib['id']
        aa.consumer_key = app.find('consumer-key').text
        aa.consumer_secret = app.find('consumer-secret').text
        app_accounts.append(aa)

    return {'users': user_accounts, 'apps': app_accounts}
    

if __name__ == "__main__":
    xml_str = """<?xml version="1.0" encoding="UTF-8"?>
<long-life-spammers>
  <user-accounts>
    <account>
      <user-name>paradomo</user-name>
      <password>admin123</password>
      <token>5de5e92de2f00d903267510ffec3c62b</token>
      <token-secret>7e4fc97d170f62d8c3f74c3900b757f2</token-secret>
      <tag>外汇</tag>
      <tag>美容</tag>
      <tag>婚庆</tag>
    </account>
  </user-accounts>

  <app-accounts>
    <account id="test">
      <consumer-key>722861218</consumer-key>
      <consumer-secret>1cfbec16db00cac0a3ad393a3e21f144</consumer-secret>
    </account>
  </app-accounts>
</long-life-spammers>
"""
    print "processing xml:\n%s" % xml_str

    config = _parse_config(ElementTree.fromstring(xml_str))
    print "\n%s\n" % ("=" * 100)
    for user in config['users']:
        print "username:%s\npassword:%s\ntoken:%s\ntoken-secret:%s\ntags:\n" % \
        (user.uname, user.passwd, user.token, user.token_secret)
        for tag in user.tags:
            print tag
        print "\n%s\n" % ("=" * 100)
    for app in config['apps']:
        print "appid:%s\nkey:%s\nsecret:%s\n" % (app.id, app.consumer_key, app.consumer_secret)
