# coding=utf-8

FILE_UPLOADS_DIR = 'file_uploads/'
MAX_NEW_FOLLOW_PER_DAY = 80


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
        if victim_num > MAX_NEW_FOLLOW_PER_DAY:
            _logger.debug("%d victim left for user(%d), skip" % (victim_num, self.user.id))
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
# post tweet
# follow new victim
# stop following stubborn
# report status
    def routine(self):
        _logger.debug("routine called for user:(%d)" % (self.user.id))
        
        if int(time.time()) < self.user.next_action_time:
            _logger.debug("too early, no action until %s" % time.ctime(local_user.next_action_time))
            return

        stat = self.agent.get_user_statistic(self.user.id)
        self.post_tweet(stat)
        _logger.debug("post tweet done for user(%d)" % self.user.id)
        self.follow_new_victims(stat)
        _logger.debug("follow new victim done for user(%d)" % self.user.id)
        self.stop_follow_stubborn(stat)
        _logger.debug("unfollow stubborn done for user(%d)" % self.user.id)

        online_stat = self.online_user_statistic()
        stat.dict.update(online_stat)
        stat.save()
        _logger.debug('db statuse updated for user:(%d)' % self.user.id)
        _logger.debug('routine finished for user:(%d)' % self.user.id)
        

    def online_user_statistic(self):
        me = self.api.me()
        stat = { 'user_id': self.user.id,
                 'collect_date': datetime.now().strftime("%Y-%m-%d"),
                 'follow_count': me.follow_count,
                 'followed_count': me.followed_count,
                 'tweet_count': me.tweet_count
                 }
        return stat


    def stop_follow_stubborn(self, stat):
        pass

# follow new victim procedure
    def follow_new_victims(self, db_stat):
        if db_stat.new_follow >= MAX_NEW_FOLLOW_PER_DAY:
            _logger.debug("user(%d) already followed %d victims today, will skip following" %
                          (self.user.id, db_stat.new_follow))
            return

        limit = MAX_NEW_FOLLOW_PER_DAY - db_stat.new_follow
        _logger.debug("user(%d) already followed %d victims today, will try %d more" %
                      (self.user.id, db_stat.new_follow, limit))

        victims = self.agent.victim_crawled.find_all({'user_id': self.user.id,
                                                      'follow_date': -1}, limit = limit)
        _logger.debug("%d victims found from DB, user:(%d)" % (len(victims), self.user.id))
        success_count = 0
        for victim in victims:
            _logger.debug("try following (%s)" % victim.victim)
            try:
                self.api.follow(target_id = victim.victim)
                _logger.debug("user(%d) followed new victim(%s)" % (self.user.id, victim.victim))
                success_count += 1
            except Exception, err:
                _logger.error("user(%d) failed to follow (%s):%s" % (self.user.id, victim.victim, traceback.format_exc()))
                return
            try:
                victim.follow_date = int(time.time())
                victim.save()
                _logger.debug("victim(%s) marked as followed by user(%d) in DB" % (victim.victim, self.user.id))
            except Exception, err:
                _logger.error("failed mark victim(%s) followed by user(%d) in DB: %s" % 
                              (victim.victim, self.user.id, err))

        db_stat.new_follow += success_count
        _logger.debug("follow victim done for user(%d), %d new victims followed" % (self.user.id, success_count))

# posting tweet procedure
    def post_tweet(self, db_stat):
        if db_stat.new_post >= 5:
            _logger.debug("user(%d) already posted %d posts today, will skip posting" % (self.user.id, db_stat.new_post))
            return
        _logger.debug("user(%d) already posted %d posts today" % (self.user.id, db_stat.new_post))

        ts = self.agent.tweet_stack.find(predicate_dict = {'user_id': self.user.id,
                                                           'published': 0})
        if ts == None:
            _logger.error("no tweet available for user(%d)" % self.user.id)
            return

        tweet = self.agent.tweet_crawled.find({'id': ts.tweet_id})
        if tweet == None:
            _logger.error("tweet(%d) can't be found in DB" % ts.tweet_id)
            self.agent.tweet_stack.remove(ts)
            return

        if tweet.image_bin != None:
            image_path = self.save_tmp_image_for_upload(tweet.image_bin)
        else:
            image_path = None

        tweet_text = self.compose_tweet(tweet)
        try:
            if image_path != None:
                _logger.debug('will upload image from (%s)' % image_path)
                self.api.publish_tweet_with_image(text = tweet_text, image_path = image_path)
            else:
                _logger.debug('will publish tweet(%s)' % tweet_text)
                self.api.publish_tweet(text = tweet_text)

        except Exception, err:
            _logger.error("failed to post new tweet(%s, image:%s): %s" % (tweet_text, image_path, traceback.format_exc()))
            return

        db_stat.new_post += 1
        # update db
        try:
            ts.published = 1
            ts.save()
            _logger.debug("tweet marked as published in DB")
        except Exception, err:
            _logger.error("tweet posted, but failed to mark it as published in DB, may result in duplicate tweet in the future: %s" % err)


    def save_tmp_image_for_upload(self, image_bin):
        if not os.path.exists(FILE_UPLOADS_DIR):
            os.mkdir(FILE_UPLOADS_DIR)
        path = os.path.join(FILE_UPLOADS_DIR, "./%d.%d.jpg" % (self.user.id, int(time.time())))
        with open(path, 'w') as output:
            output.write(image_bin)
            return path
                               
    def compose_tweet(self, tweet):
        title = u'【%s】' % tweet.title.decode('utf-8')
        content = tweet.content.decode('utf-8')
        href = tweet.href

        content_len = 140 - 25  - len(title)
        content = "%s%s...%s" % (title, content[:content_len], href)
        return content.encode('utf-8')
        

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

