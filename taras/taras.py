# coding=utf-8
import os, sys, re, random, cPickle, traceback, urllib, time, signal, hashlib, math

from ConfigParser import RawConfigParser
from datetime import datetime, timedelta, date
from functools import partial
from pprint import pprint

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../third_party')

from third_party.BeautifulSoup import BeautifulSoup
from third_party import chardet
from util.log import _logger
from util import pbrowser
from util import util
from sql_agent import SQLAgent, Tweet
from tcrawler import try_crawl_href, recursive_crawl, Aster
from third_party.selenium import selenium
from keyword_tree import KeywordElem
import api_adapter

def handle_sig(sig, frame):
    pass

class Taras(object):
    def __init__(self, api_type, agent):
        self.api_type = api_type
        self.agent = agent
        self.api = None

    def get_token(self, user, app):
        raw_token = self.agent.get_token(user.id, app['id'])
        if (raw_token):
            return cPickle.loads(raw_token)
        
        token = self.api.create_token_from_web(user.identity, user.passwd)
        self.agent.update_token(user.id, app['id'], cPickle.dumps(token))
        return token
            
    def select_app_for_user(self, user):
        all_app = self.agent.get_all_app()
        return all_app[user.id % len(all_app)]

    def assign_user(self, user, app=None):
        APIClass = api_adapter.create_adapted_api(self.api_type)
        if not app:
            app = self.select_app_for_user(user)
        self.api = APIClass(app['token'], app['secret'])
        token = self.get_token(user, app)
        self.api.create_api_from_token(token)
        #print self.api.public_timeline()[0].text

    def crawl_victim(self):
        _logger.debug('crawl_victim called from %s' % (self.api.me().name))

if __name__ == "__main__":
    _logger.info("Testing Taras functions")
    agent = SQLAgent('taras_qq', 'junyi', 'admin123')
    agent.start()
    taras = Taras("qq", agent)
    all_users = agent.get_all_user()
    all_app = agent.get_all_app()
    taras.assign_user(all_users[0], all_app[0])
    agent.stop()

    sys.exit(0)


    # parse config
    config_path = os.path.dirname(os.path.abspath(__file__)) + '/config'
    _logger.info('reading config from %s' % config_path)
    config = RawConfigParser()
    config.read(config_path)
    if (len(config.sections()) < 1):
        _logger.fatal('failed to read config file from %s' % config_path)


    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'hu:p:d:s:a:c:', ['help', 'user=', 'passwd=', 'database=', 'shard=', 'all-shard=', 'command='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()

    usage_only = False
    dbname = 'taras'
    dbuser = 'taras'
    dbpass = 'admin123'
    shard_id = 0
    shard_count = 1
    command = 'unset'
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage_only = True
        if opt in ('-u', '--user'):
            dbuser = arg
        if opt in ('-p', '--passwd'):
            dbpass = arg
        if opt in ('-d', '--database'):
            dbname = arg
        if opt in ('-s', '--shard'):
            shard_id = int(arg)
        if opt in ('-a', '--all-shard'):
            shard_count = int(arg)
        if opt in ('-c', '--command'):
            command = arg


    if usage_only:
        usage()

    if dbuser == "":
        print '-u(--user=) must be provided'
        usage()
    if dbname == "":
        print '-d(--database=) must be provided'
        usage()
    if dbpass == "":
        print '-p(--passwd=) must be provided'
        usage()

    _logger.info('shard_id = %d, shard_count = %d, command = (%s)' % (shard_id, shard_count, command))

    noselenium = True
    if command == 'daemon':
        daemon = WeiboDaemon(dbname, dbuser, dbpass, noselenium = noselenium, mysql_host = config.get('global', 'mysql_host_for_daemon'))
        signal.signal(signal.SIGINT, daemon.handle_int)
        daemon.daemon(shard_id=shard_id, shard_count=shard_count)
    elif command == 'crawl-tweet':
        noselenium = False
        daemon = WeiboDaemon(dbname, dbuser, dbpass, noselenium = noselenium)
        signal.signal(signal.SIGINT, daemon.handle_int)
        daemon.crawl_tweet_daemon(shard_id, shard_count)
    elif command == 'crawl-victim':
        daemon = WeiboDaemon(dbname, dbuser, dbpass, noselenium = noselenium)
        signal.signal(signal.SIGINT, daemon.handle_int)
        daemon.crawl_victim_daemon(shard_id, shard_count)
    elif command == 'index-tweet':
        import tindexer
        indexer = tindexer.TIndexer()
        indexer.start_indexer_daemon(dbname, dbuser, dbpass)
    else:
        _logger.error('unknown command: (%s)' % command)
        usage()
