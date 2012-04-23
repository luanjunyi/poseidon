# coding=utf-8
import os, sys, re, random, cPickle, traceback, time, math
import urllib2, socks

from ConfigParser import RawConfigParser
from datetime import datetime, timedelta, date
from functools import partial
from proxy_manager import ProxyManager

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../third_party')

from BeautifulSoup import BeautifulSoup
from util.log import _logger
import sql_agent
import api_adapter


class Taras(object):
    def __init__(self, api_type, agent):
        self.api_type = api_type
        self.agent = agent
        self.api = None
        self.user = None
        self.proxy_manager = ProxyManager(agent)

# Authorization
    def get_token(self, user, app):
        raw_token = self.agent.app_auth_token.find({'user_id': user.id,
                                                    'app_id': app.id})
        if (raw_token):
            return cPickle.loads(raw_token.value)
        
        token = self.api.create_token_from_web(user.identity, user.passwd)
        self.agent.app_auth_token.add({'user_id': user.id,
                                       'app_id': app.id,
                                       'value': cPickle.dumps(token)}, force=True)
        return token
            
    def select_app_for_user(self, user):
        all_app = self.agent.local_app.find_all()
        return all_app[user.id % len(all_app)]

    def assign_user(self, user, app=None):
        _logger.debug("assgining user id=%d", user.id)
        self.user = user
        APIClass = api_adapter.create_adapted_api(self.api_type)
        if not app:
            app = self.select_app_for_user(user)
        self.api = APIClass(app.token, app.secret)
        token = self.get_token(user, app)
        self.api.create_api_from_token(token)

        # Pass user ID to native API, so that binder will use proxy manger to get
        # a properly proxied connection
        self.api.api.proxy_manager = self.proxy_manager
        self.api.api.user_id = self.user.id  

        _logger.debug("%s assigned as user" % self.api.me().name)

# Crawl victim
    def find_victim_by_keyword(self, keyword):
        _logger.debug('finding victim for user(%d) using keyword(%s)' % (self.user.id, keyword))
        tweets = self.api.search_tweet(query=keyword)[:200]
        _logger.debug('%d tweets found with keyword(%s)' % (len(tweets), keyword))
        return [str(tweet.user_id) for tweet in tweets]

    def crawl_victim(self):
        _logger.debug('crawl_victim called for user:(%d)' % (self.user.id))

        victim_num = self.agent.victim_crawled.get_row_num({'user_id': self.user.id})
        if victim_num > 200:
            _logger.debug("%d vicitm left for user(%d), skip" % (victim_num, self.user.id))
            return

        victims = set()
        victim_keywords = self.user.victim_keywords
        for word in victim_keywords:
            new_victims = self.find_victim_by_keyword(word)
            for victim in new_victims:
                if not self.agent.victim_crawled.exists({'user_id': self.user.id,
                                                     'victim': victim}):
                    victims.add(victim)

        
        added_count = self.agent.add_victims(self.user.id, victims)

        _logger.debug('crawl_victim done for user:(%d), %d found, %d added' %
                      (self.user.id, len(victims), added_count))

# Index tweet
    def clean_content(self, content):
        soup = BeautifulSoup(content)
        return soup.text[:140].encode('utf-8')

    def find_tweet(self, tweet_agent):

        _logger.debug("find_tweet called for user:(%s)" % (self.user.id))
        if (self.user.index_date == -1):
            _logger.debug("need add user's tags as custom tags")
            tweet_agent.add_custom_tags(self.user.tags)

        for tag in self.user.tags:
            wee_ids = tweet_agent.get_wee_id_containing_term(tag)
            _logger.debug("%d tweets found for tag(%s)" % (len(wee_ids), tag))
            fetch_ids = []


            for wee_id in wee_ids:
                if not self.agent.tweet_crawled.exists({'id': wee_id}):
                    fetch_ids.append(wee_id)
                else:
                    _logger.debug("tweet id=%d exists in DB, ignore" % wee_id)
            fetched_tweets = tweet_agent.wee.find_many(('id', ), fetch_ids)
            _logger.debug("(%d/%d) new tweets fetched from tweet agent" % (len(fetched_tweets), len(fetch_ids)))
            if len(fetch_ids) != len(fetched_tweets):
                sys.exit(0)
            for tweet in fetched_tweets:
                store = {'title': tweet.title,
                         'content': self.clean_content(tweet.html),
                         'href': tweet.url,
                         'image_bin': tweet.image_bin,
                         'id': tweet.id,
                         'created_at': tweet.updated_time
                         }
                if not self.agent.tweet_crawled.exists({'title': store['title']}):
                    try:
                        self.agent.tweet_crawled.add(store)
                    except Exception, err:
                        _logger.debug("adding tweet to DB failed: %s" % err)
                        wee_ids.remove(tweet.id)

            self.agent.tweet_stack.add_many(['user_id', 'tweet_id'],
                                            [(self.user.id, wee_id) for wee_id in wee_ids])

        self.user.index_date = int(time.time())
        self.user.save()

# Action routine
    def routine(self):
        pass

if __name__ == "__main__":
    _logger.info("Testing Taras functions")
    agent = sql_agent.init('taras_qq', 'junyi', 'admin123')
    agent.start()

    all_users = agent.get_all_user()
    all_app = agent.local_app.find_all()
    
    for user in all_users:
        taras = Taras("qq", agent)
        taras.assign_user(user, all_app[0])
        t = taras.api.public_timeline()[0]
        print t.text
        # tweet_text = '心情很好，愿世界永远和平! %f' % time.time()
        # taras.api.update_status(text=tweet_text)
        # _logger.debug('%s published' % tweet_text)

    agent.stop()

    sys.exit(0)

