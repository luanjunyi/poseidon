# -*- coding: utf-8 -*-
import os, sys, re, random, cPickle, traceback, urllib, time, signal, hashlib
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
from tcrawler import try_crawl_href, recursive_crawl
from third_party.selenium import selenium
from keyword_tree import KeywordElem

from third_party.weibopy import auth as sina_auth
from third_party.weibopy import API as sina_api
from third_party.weibopy import WeibopError

def handle_sig(sig, frame):
    pass

class WeiboDaemon:
    def __init__(self, dbname = "taras", dbuser = "taras", dbpass = "admin123",
                 treefile = '', noselenium = False, selenium_timeout_minute = 2,
                 mysql_host = "localhost"):
        # Parse configuration
        config_path = os.path.dirname(os.path.abspath(__file__)) + '/config'
        _logger.info('reading config from %s' % config_path)
        self.config = RawConfigParser()
        self.config.read(config_path)
        if (len(self.config.sections()) < 1):
            _logger.fatal('failed to read config file from %s' % config_path)
        if treefile == '':
            treefile = os.path.dirname(os.path.abspath(__file__)) + '/tree.txt'
        # Create keyword tree
        try:
            _logger.info('making Keyword Tree')
            self.ktree = KeywordElem(treefile = treefile)
        except Exception, err:
            _logger.error('failed to create keyword tree from(%s): %s' % (treefile, err))
        # Connect to DB
        _logger.info('starting MySQL client, db:%s, user:%s, passwd:%s' % (dbname, dbuser, dbpass))
        self.agent = SQLAgent(dbname, dbuser, dbpass, mysql_host)
        # Start Selenium client
        if not noselenium:
            self.selenium = selenium('localhost', 4444, 'firefox', 'http://www.baidu.com')
            _logger.info('starting selenium')
            self.selenium.start()
            self.selenium.set_timeout(selenium_timeout_minute * 60 * 1000) # timeout 120 seconds

        # Set shard_id
        self.shard_id = 0

    def _duplicate_tweet(self, new_content):
        if not hasattr(self, 'user'):
            return False
        try:
            user = self.user
            _logger.debug('fetching published tweet from DB, user:(%s)' % user.uname)
            all_tweets = self.agent.get_tweet_log(user.uname)
        except Exception, err:
            _logger.error('failed to get last 200 user\'s timeline: %s' % err)
            return self.config.getboolean('global', 'see_as_duplicate_when_user_timeline_unavialable')

        new = new_content
        _logger.debug('new tweet in dedup:(%s)' % new)

        for old in all_tweets:
            similarity = util.match_ratio(old.decode('utf-8'), new.decode('utf-8'))
            if similarity >= 0.7:
                _logger.debug('duplicate(%3f) with tweet:(%s)' % (similarity, old))
                return True
        return False

    def _parse_xpath(self, xpath, attr=None):
        try:
            if attr == None:
                locator = "xpath=%s" % xpath
                return self.selenium.get_text(locator)
            else:
                locator = "xpath=%s@%s" % (xpath, attr)
                return self.selenium.get_attribute(locator)
        except Exception, err:
            _logger.error('parse xpath(%s, attr:(%s)) failed: %s %s' % (xpath, str(attr), err, traceback.format_exc()))
            return ''

    # Crawl content from 'baseurl', if query is not None, use it as keyword(something like news.baidu.com)
    # query if provided, must be of unicode type
    def create_tweet(self, source, query, limit=140):
        # prepare URL
        url = source.base_url
        if source.need_query:
            if type(query) != unicode:
                _logger.error("query must be unicode, got %s" % str(type(query)))
            query = urllib.quote_plus(query.encode(source.encoding))
            _logger.debug("query encoded as (%s)" % (query))
            url += query
        # fetch web page and preprocess
        _logger.debug('creating tweet: source(%s), url(%s)' % (source.id, url))
        # Get random source item
        source_item = self.agent.get_random_source_item(source.id)
        _logger.debug('using xpath, title:(%s), content:(%s), image:(%s), href:(%s)' %
                      (source_item.title, source_item.content, source_item.image, source_item.href))
        title_xpath = source_item.title
        content_xpath = source_item.content
        image_xpath = source_item.image
        href_xpath = source_item.href

        if not source.need_query:
            # fetch tweet from DB
            tweet = self.agent.fetch_tweet(source.id, source_item.id)
            if tweet != None:
                _logger.debug('tweet fetched from DB, (%s, %d)' % (source.id, source_item.id))
                self.agent.remove_tweet(source.id, source_item.id)
                return self._compose_tweet(tweet)
            else:
                _logger.debug('failed to fetch tweet from DB, (%s, %s)' % (source.id, source_item.id))

        # crawl tweet on the spot
        self._prepare_webpage(url, source.encoding)
        return self._create_fresh_tweet(title_xpath, content_xpath, image_xpath, href_xpath, source.encoding, url)

    def _prepare_webpage(self, url, encoding):
        _logger.debug('opening %s' % url)        
        self.selenium.open(url)
        _logger.debug('url: %s, loaded' % url)

    def _compose_tweet(self, tweet):
        _logger.debug('composing tweet: title(%s), content(%s), href(%s), image_ext(%s), has_image(%d)',
                      tweet.title, tweet.content, tweet.href, tweet.image_ext, tweet.image_bin != None)

        # If no content, set title as content
        if tweet.content == '':
            tweet.content = tweet.title
            tweet.title = ''

        if tweet.title != '':
            tweet.title = (r'【%s】' % tweet.title)
        # if random.randint(1, 3) > 1: # 2/3 of tweet should have no title
        #     tweet.title = ''


        text = ('%s %s ' % (tweet.title, tweet.content))
        text = text.strip()

        if tweet.href != '':
            text += '...  %s' % tweet.href

        _logger.debug('tweet composed:%s' % (text))

        if len(text) < 2:
            _logger.debug('combined title and content, I got(%s), probably from empty title and content, will abort'
                          % text)
            raise Exception('near empty tweet composed, I\'m shame of myself')


        # Parse image
        # First do some clean up, the code shouldn't belong here, but it's very convinient this way
        os.system('rm -f *.upload.*')

        image_path = ''
        if tweet.image_ext == None:
            tweet.image_ext = '.jpg'
        if tweet.image_bin != None:
            image_path = "%d.upload%s" % (int(time.mktime(datetime.now().timetuple())),
                                              tweet.image_ext)
            with open(image_path, 'w') as image_file:
                image_file.write(tweet.image_bin)
                if type(image_path) == unicode:
                    image_path = image_path.encode('utf-8')

        return text, image_path



    def _create_fresh_tweet(self, title_xpath, content_xpath, image_xpath, href_xpath, encoding, url):
        tweet = self._crawl_tweet_internal(title_xpath, content_xpath, image_xpath, href_xpath, encoding, url)
        return self._compose_tweet(tweet)

    def _clean_stubborn(self, user, ruthless=False):
        if not hasattr(self, 'user') or self.user != user:
            self.assign_user(user)
        weibo = self.weibo
        followings = weibo.friends_ids().ids
        now = datetime.now()
        me = self.me
        _logger.debug('nick: %s, following %d, handling %d of them' % (me.name.encode('utf-8'), me.friends_count, len(followings)))
        for followee_id in followings:
            try:
                if weibo.exists_friendship(followee_id, me.id).friends:
                    # OK if that followee has followed us
                    _logger.info('%d is following me' % followee_id)
                    continue

                if ruthless and me.friends_count >= 1800:
                    weibo.destroy_friendship(user_id=followee_id)
                    self.agent.stop_follow(user, followee_id)
                    _logger.info('%s ruthlessly stop following %d' % (user.uname, followee_id))
                    continue

                start_following_date = self.agent.get_follow_date(user, followee_id)
                if start_following_date == None:
                    self.agent.update_follow_date(user, str(followee_id), now)
                    _logger.info('%d monitoring date added: %s' % (followee_id, str(now)))
                    continue
                # Stop following this bastard if it has been more than 14 days since we
                # followed him
                monitored_day = (now - start_following_date).days
                if monitored_day > 4:
                    weibo.destroy_friendship(user_id=followee_id)
                    self.agent.stop_follow(user, followee_id)
                    _logger.info('%s stop following %d' % (user.uname, followee_id))
                else:
                    _logger.info('%s in monitor day %d' % (followee_id, monitored_day))
            except Exception, err:
                _logger.error('error when handling relationship between %s and %d: %s' %\
                                  (user.uname, followee_id, err))

            self.sleep_random(1, 1)

    def force_stop_follow_stubborn(self, email=None):
        if email == None:
            _logger.info('cleaning following for all user')
            users = self.agent.get_all_user()
            for user in users:
                try:
                    self._clean_stubborn(user, ruthless=True)
                except Exception, err:
                    _logger.error('clean_following failed: %s' % (err))
        else:
            _logger.info('cleaning following for %s' % email)
            user = self.agent.get_user_by_email(email)
            self._clean_stubborn(user, ruthless=True)

    def stop_follow_stubborn(self):
        # This cost time, do it only on Weekends
        if not (datetime.now().hour >= 20 or datetime.now().hour <= 7):
            _logger.debug('too early to consider stop follow stubborn only do it after 20:00')
            return
        if int(hashlib.md5(self.user.uname).hexdigest(), 16) % 2 == datetime.now().day % 2:
            # my clean stubborn day
            _logger.debug('my clean stobborn day checking clean history')
            date = datetime.now().strftime('%Y-%m-%d')
            if self.agent.is_stubborn_cleaned(self.user.uname, date):
                _logger.debug('my clean stobborn day but has cleaned already')
                return
            _logger.info('cleanning subborn now')
            self._clean_stubborn(self.user)
            self.agent.mark_stubborn_cleaned(self.user.uname, date)
            _logger.info('cleanning subborn finished')


    def authorize_app(self, uname, passwd, app):
        br = pbrowser.get_browser()
        _logger.debug('getting authorize URL')
        handle = sina_auth.OAuthHandler(app.consumer_key, app.consumer_secret)
        # get pin code
        auth_url = handle.get_authorization_url()
        _logger.debug('opening authorize URL:%s' % auth_url)
        br.open(auth_url)
        br.select_form(nr=0)
        br.form['userId'] = uname
        br.form['passwd'] = passwd
        html = br.submit().read()
        soup = BeautifulSoup(html)
        # there are two kinds of pages encountered so far, try them one by one
        try:
            pin = soup.find('span', 'fb').find(text=True).encode()
        except:
            try:
                pin = soup.find('font', size="4").find(text=True)
                pin = re.search('[0-9]+', pin).group().encode()
            except Exception, err:

                # Tempary solution
                with open('bad_id_detected', 'a') as bad_id:
                    bad_id.write('%s:%s\n' % (uname, passwd))
                    bad_id.flush()
                self.agent.disable_user(uname)

                dumppath = util.dump2file_with_date(html)
                raise Exception('getting authrization pin code failed: %s, page dumped to %s, %s' %
                                (err, dumppath, traceback.format_exc()))
                

        _logger.debug('pin code fetched:%s' % pin)
        # get token
        return handle.get_access_token(pin)

    def get_token(self, user, app):
        # Try get token from DB, test it. If failed, try get token
        # ourselves and store the token in DB
        rawtoken = self.agent.get_token(user.uname, app.id)
        if rawtoken != None:
            return cPickle.loads(rawtoken)

        token = self.authorize_app(user.uname, user.passwd, app)
        if not self.agent.update_token(user.uname, app.id, cPickle.dumps(token)):
            _logger.error('failed to update token, but the authorized token will be returned')
        return token

    def get_api_by_user(self, email):
        """
        Given an Email address, return the user's API object
        """
        user = self.agent.get_user_by_email(email)
        app = random.choice(self.agent.get_all_app())
        token = self.get_token(user, app)
        handle = sina_auth.OAuthHandler(app.consumer_key, app.consumer_secret)
        handle.setToken(token=token.key, tokenSecret=token.secret)
        _logger.debug('creating api')
        api = sina_api(handle)
        # test api, will raise Exception if the user is blocked
        _logger.debug('trying api.me()')
        api.taras = self
        self.me = api.me()
        return api

    def freeze_user(self, user=None):
        if user == None:
            user = self.user

        last_action_time = self.agent.get_last_action_time(user)
        if last_action_time == None:
            _logger.error("can\'t find last action time in user statistic, will skip freezening ")
            return

        now = datetime.now()
        dead_day = (now - last_action_time).days
        if dead_day < 3:
            _logger.debug('%s only dead for %d day, skip freezening' % (user.uname, dead_day))
            return
        freeze_to = now + timedelta(days = dead_day)
        _logger.debug('will freeze for %d days, to %s' % (dead_day, str(freeze_to)))
        self.agent.update_next_action_time(user, freeze_to)


    def post_tweet(self):
        _logger.info('start post_tweet')
        # Fill me up if new user
        if len(self.weibo.user_timeline(feature=1)) < 10:
            _logger.debug('less than 10 tweets, fill up')
            for i in range(10):
                if not self.post_one_tweet():
                    _logger.error('post one tweet failed, I have to give up for now')
                    break
                else:
                    _logger.info('posted one tweet')
                self.sleep_random(1, 2)
        else:
            new_tweet_count = self.get_new_tweet_count()
            if new_tweet_count >= 5 + len(self.user.uname) % 3:
                _logger.info('skip tweet, %d new tweet published today' % new_tweet_count)
                return
            mentions = []
            if random.randint(1, 10) == 11:
                if random.randint(0, 10) == 0: # mention one follower
                    _logger.debug('will @ one follower')
                    uid = random.choice(self.weibo.followers_ids(count = 5000).ids)
                else: # mention one followee
                    _logger.debug('will @ one followee')
                    uid = random.choice(self.weibo.friends_ids(count = 5000).ids)
                mentions.append(self.weibo.get_user(user_id=uid).screen_name)
            else:
                _logger.debug('will not @ anyone')
            self.post_one_tweet(mentions)
        _logger.info('end post_tweet')

    def _valid_tweet(self, tweet):
        if not hasattr(self, 'user'):
            return True

        bad_word = ['|',
                    '– –'
                    '请联系',
                    '仅售',
                    '报价',
                    '■',
                    '□',
                    ]

        bad_word.extend(self.agent.get_global_bad_words())

        for bad in bad_word:
            try:
                tweet.index(bad)
                _logger.debug('tweet contain bad word:(%s)' % bad)
                return False
            except:
                pass
        if self._duplicate_tweet(tweet):
            _logger.debug('tweet detected as duplicate')
            return False
        return True



    def _get_random_source_by_category(self, category):
        _logger.debug('finding source for category(%s)' % category.encode('utf-8'))
        return self.agent.get_source_by_tag(category.encode('utf-8'))

    def _choose_source_for_user(self, user):
        """
        Choose a tweet source for user.
        Order of preference:
        1. Source specified directly for this user in DB
        2. The source with the same tag user category (one of user.categries)
        3. The source with the same tag as one children of user category (one of user.categries)
        4. The source with the same tag as parent of user category (one of user.categries)
        """
        if len(user.sources) > 0:
            _logger.debug('user has sources specified, will choose from there')
            return self.agent.get_source(random.choice(user.sources))

        tag = random.choice(user.categories)
        source = self._get_random_source_by_category(tag)
        if source != None:
            _logger.debug('got source by exact tag match(%s)' % tag.encode('utf-8'))
            return source

        if hasattr(self, 'ktree'):
            # choose from children
            tag_node = self.ktree[tag]
            if tag_node != None:
                for child in tag_node.children:
                    source = self._get_random_source_by_category(child.content)
                    if source != None:
                        _logger.debug('got source by child tag match(%s)'
                                      % child.content.encode('utf-8'))
                        return source
                # choose from parent
                parent = tag_node.parent
                if parent != None and hasattr(parent, 'content'):
                    source = self._get_random_source_by_category(parent.content)
                    if source != None:
                        _logger.debug('got source by parent tag match(%s)'
                                      % parent.content.encode('utf-8'))
                        return source

        _logger.debug('can\'t find tag-matched source from DB, will use one safe source like news.baidu.com')
        return self.agent.get_safe_source()

    def truncate_tweet(self, tweet, mention_text):
        tail = tweet.find('...  ')
        if tail != -1:
            mention_text = tweet[tail:] + ' ' + mention_text
            tweet = tweet[:tail]
        tail_len = util.weird_char_count(mention_text)
        _logger.debug('%d chars truncated' % (len(tweet) - (140 - tail_len)))
        return tweet[:(140 - tail_len)] + mention_text

    def post_one_tweet(self, mentions=[]):
        while True:
            raw_tweet = self.agent.pop_tweet_stack(self.user.uname)
            if raw_tweet == None:
                _logger.debug('failed to find tweet from tweet_stack')
                return
            _logger.debug('raw tweet fetched from tweet_stack in DB')
            tweet_text, img_path = self._compose_tweet(raw_tweet)

            if not self._valid_tweet(tweet_text):
                _logger.error('invalid tweet:(%s)' % tweet_text)
                continue
            else:
                _logger.debug('tweet passed validity test:(%s)' % tweet_text)

            tweet = tweet_text.decode('utf-8')
            mention_text = ''
            break

        # Add @
        for mention in mentions:
            mention_text += ' @%s' % mention.encode('utf-8')
        mention_text = mention_text.decode('utf-8')
        # deal with the tweet-140 constraint
        tweet = self.truncate_tweet(tweet, mention_text)
        tweet = tweet.encode('utf-8')

        try:
            if img_path != '':
                self.weibo.upload(filename=img_path, status=tweet)
            else:
                self.weibo.update_status(status=tweet)
        except WeibopError, err:
            _logger.error('WeiboError: %s' % (err))
            return False
        except Exception, err:
            _logger.error('failed to publish new tweet: %s, %s' % (err, traceback.format_exc()))
            return False
        else:
            # Insert tweet to DB
            self.agent.add_tweet_log(tweet_text, self.user.uname)
            _logger.info('posted new tweet:(%s), user:(%s)' %
                         (tweet, self.user.uname))
            return True

    def be_friendly(self):
        # To get maximum 
        _logger.info('start be friendly')

        if self.me.friends_count >= 1950:
            _logger.info("too much followee(%d), will ruthlessly remove some" % self.me.friends_count)
            self._clean_stubborn(self.user, ruthless = True)

        count = random.randint(50, 60)

        follow_delta = self.get_new_follow_count()

        if follow_delta >= 200:
            _logger.debug("follow_delta is %d, larger than 200, will not follow anyone" % follow_delta)
            count = 0
        else:
            if count > 200 - follow_delta:
                count = 200 - follow_delta

        _logger.debug('will touch %d people' % count)
        victims = self.agent.get_victims(self.user, count)
        _logger.debug('%d victim fetched from DB' % len(victims))
        for victim in victims:
            try:
                self.be_friendly_once(victim)
            except Exception, err:
                _logger.error('got exception, I\'ve to give up for now: %s' % err)
                break
        _logger.info('end be friendly')

    def be_friendly_once(self, victim_id):
        # disable use the following for now
        # Comment on his tweet, add invitation
        # try:
        #     victim_user = self.weibo.get_user(screen_name = victim)
        #     comment_tweet = random.choice(victim_user.timeline())
        #     comment = self.agent.get_random_comment()
        #     self.weibo.comment(id=comment_tweet.id, comment=comment)
        #     _logger.debug('friendly commented(%s):%s' % (victim.encode('utf-8'), comment))
        # except Exception, err:
        #     _logger.error('failed to friendly comment(%s):%s' % (victim.encode('utf-8'), err))
        #     _logger.error(traceback.format_exc())
        # @him in my tweet
        # if random.randint(0, 20) == 21:
        #     try:
        #         if self.post_one_tweet([victim]) == True:
        #             _logger.debug('friendly @(%s)tweeted' % (victim.encode('utf-8')))
        #         else:
        #             _logger.error('failed to friendly @(%s)tweeted' % (victim.encode('utf-8')))
        #     except Exception, err:
        #         _logger.error('failed to friendly @tweet (%s):%s' % (victim.encode('utf-8'), err))
        #         _logger.error(traceback.format_exc())

        # follow him
        try:
            self.weibo.create_friendship(user_id=victim_id)
            self.agent.add_follow_log(self.user.uname, str(victim_id))
            _logger.info('friendly followed %d' % victim_id)
        except WeibopError, err:
            _logger.error('failed to friendly follow victim_id=(%d), WeiboError: %s' % (victim_id, err))
            raise err
        except Exception, err:
            _logger.error('failed to friendly follow %d, %s' % (victim_id, traceback.format_exc()))
        finally:
            try:
                self.agent.remove_victim(self.user, victim_id)
            except Exception, err:
                _logger.error('failed to delete victim from db(%s:%d): %s' % (self.user.uname, victim_id, err))

    def get_sina_id(self, user):
        token = self.get_token(user, self.app)
        handle = sina_auth.OAuthHandler(self.app.consumer_key, self.app.consumer_secret)
        handle.setToken(token=token.key, tokenSecret=token.secret)
        o_api = sina_api(handle)
        _logger.debug("fetch sina_id, api generated for user(%s)" % user.uname)
        user.sina_id = o_api.me().id
        self.agent.update_sina_id(user)
        return user.sina_id

    def retweet(self):
        """
        Randomly choose an account that share at least one same category with self.user,
        and retweet one of her tweets.
        """
        _logger.info('start retweet')
        if random.randint(0, 120) != 121: # disable for now
            _logger.debug('skip retweeting')
            return

        # Get users share the same category
        me = self.me
        all_users = self.agent.get_all_user()
        candidates = []
        for candidate in all_users:
            if candidate.uname == self.user.uname:
                continue
            for other_cate in candidate.categories:
                try:
                    self.user.categories.index(other_cate)
                    candidates.append(candidate)
                    break
                except:
                    pass
        _logger.debug('got %d retweet account candidates' % len(candidates))
        if len(candidates) == 0:
            return
        candidate = random.choice(candidates)
        if candidate.sina_id == 0:
            self.get_sina_id(candidate)
        try:
            uid = candidate.sina_id
            ally = self.weibo.get_user(user_id=uid)
        except Exception, err:
            _logger.error('failed to find user by id(%s):%s' % (uid, err))
            
        _logger.debug('will retweet from %s' % ally.name.encode('utf-8'))
        try:
            tweet = random.choice(ally.timeline())
            tweet.retweet()
            _logger.debug('%s retweeted from (%s): %s' % (me.name.encode('utf-8'), ally.name.encode('utf-8'), tweet.text.encode('utf-8')))
        except Exception, err:
            _logger.error('failed to retweet (%s):%s:%s, %s' %
                          (ally.name.encode('utf-8'), tweet.text.encode('utf-8'), err, traceback.format_exc()))
        _logger.info('end retweet')

    def direct_message(self):
        if random.randint(0, 8) == 9:
            _logger.debug("skip random message")
            return
        with open("messages") as msg_f:
            msg = random.choice(filter(lambda i: len(i) > 0, msg_f.read().split('\n')))
        followers = self.weibo.followers(count=200)
        try:
            enc = chardet.detect(msg)
        except Exception, err:
            _logger.error('can\'t detect message encoding:%s, will assume utf-8' % err)
            enc = {'encoding': 'utf-8', 'confidence': 'pure guess'}

        _logger.debug('message encoding guess:%s' % str(enc))
        enc = enc['encoding']
        try:
            msg = msg.decode(enc).encode('utf-8')
            if len(followers) == 0:
                _logger.debug('can\'t send PM since this account(%s) has no follower' % self.user.uname)
                return
            victim = random.choice(followers)
            _logger.debug('sending message(%s) to %s' % (msg, victim.name.encode('utf-8')))
            self.weibo.new_direct_message(id=victim.id, text=urllib.quote_plus(msg))
            _logger.debug('sent message(%s) to %s' % (msg, victim.name.encode('utf-8')))
        except Exception, err:
            _logger.debug('failed to send direct message:%s, %s' % (err, traceback.format_exc()))

    def execute_action(self, action):
        _logger.debug('executing force action(%s, %s), user:%s' % (action.type, action.value, self.user.uname))
        if action.type == 'tweet':
            try:
                self.weibo.update_status(status = action.value)
                _logger.debug('(%s) force tweeted:%s' % (self.user.uname, action.value))

            except WeibopError, err:
                _logger.error('WeiboError: %s' % err)
            except Exception, err:
                _logger.error('(%s) failed to force tweet(%s):%s' % (self.user.uname, action.value, err))
        elif action.type == 'retweet':
            try:
                tweet_id = long(action.value)
                self.weibo.retweet(id = tweet_id)
                _logger.debug('(%s) force tweeted:%d' % (self.user.uname, tweet_id))
            except Exception, err:
                _logger.error('(%s) failed to force Retweet(%d):%s' % (self.user.uname, tweet_id, err))
        elif action.type == 'follow':
            try:
                self.weibo.create_friendship(id=action.value)
                _logger.debug('(%s) force followd:%s' % (self.user.uname, action.value))
            except Exception, err:
                _logger.error('(%s) failed to force follow(%s):%s' % (self.user.uname, action.value, err))
        else:
            _logger.error('unknown force action type:%s' % action.type)

    def force_action(self):
        """
        Execute actions from 'force_action', if the category match user's category
        tweet:Why so serious?
        follow:johny_walker
        retweet:1059232712
        """
        _logger.debug('will execute commands from db.force_action')
        actions = self.agent.get_all_force_action()
        for action in actions:
            if len(action.categories) == 0:
                self.execute_action(action)
                continue
            for action_cate in action.categories:
                try:
                    self.user.categories.index(action_cate)
                    self.execute_action(action)
                    break
                except Exception, err:
                    pass

    ###############################################
    # end various behavior
    ##############################################

    def get_new_follow_count(self):
        me = self.me
        old_follow_count = self.agent.get_yesterday_follow_count(self.user)
        if old_follow_count == -1:
            _logger.debug('can\'t find yesterday statistic for (%s)' % self.user.uname)
            return 0
        else:
            follow_delta = me.friends_count - old_follow_count
            _logger.debug("new follow count is %d, old:%d, cur:%d" % (follow_delta, old_follow_count, me.friends_count))
            return follow_delta

    def get_new_tweet_count(self):
        me = self.me
        old_tweet_count = self.agent.get_yesterday_tweet_count(self.user)
        if old_tweet_count == -1:
            _logger.debug('can\'t find yesterday statistic for (%s)' % self.user.uname)
            return 0
        else:
            tweet_delta = me.statuses_count - old_tweet_count
            _logger.debug("new tweet count is %d" % tweet_delta)
            return tweet_delta

    def _tomorrow_eight(self):
        return date.today() + timedelta(days=1)

    def _schedule_next_action(self):
        """
        Return next action time. This function has a side effect: if now is passed midnight,
        will do once-a-day tasks like adding WeiQun and clean followings.
        """
        MINUTE = 60
        HOUR = 3600
        now = datetime.now()

        follow_delta = self.get_new_follow_count()

        if follow_delta >= 190: # already followed enough today, rest
            next_action_time = self._tomorrow_eight()
        else:
            next_action_time = now + timedelta(seconds = 60 * random.randint(50, 70))

        _logger.debug('next action time: %s' % str(next_action_time))
        return next_action_time

    def _get_unused_category(self, users):
        def unused(node):
            for user in users:
                try:
                    user.categories.index(node.content)
                    return False
                except:
                    pass
            return True
        
        node =  self.ktree.find(partial(unused))
        if node != None:
            return node.content
        else:
            return None

    def _login_sina_weibo(self, user):
        _logger.debug('logging in to t.cn %s:%s' % (user.uname, user.passwd))
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
            self.selenium.type('id=loginname', user.uname)
            self.selenium.type('id=password', user.passwd)
            self.selenium.type('id=password_text', user.passwd)
            self.selenium.uncheck('id=remusrname')
            self.selenium.click('id=login_submit_btn')
        except Exception, err:
            dumppath = util.dump2file_with_date(self.selenium.get_html_source())
            raise Exception('filling t.cn login form failed: %s, page dumped to %s' % (err, dumppath))
        _logger.debug('loading profile page')
        self._wait_load()
        _logger.debug('logged in')

    # This method relay's purely on Selenium. So very unstable to sina's page modification
    def grouping(self, force=False):
        """ Join some 微群 """
        if random.randint(1, 10) > 1 and not force:
            _logger.debug('skip grouping')
            return

        self._login_sina_weibo(self.user)
        # fill query
        query = random.choice(self.user.categories)
        _logger.debug('filling search query using (%s)' % query.encode('utf-8'))
        self.selenium.type('m_keyword', query)
        _logger.debug('submitting query')
        self.selenium.click('m_submit')
        self._wait_load()

        _logger.debug('opening group searching result')
        self.selenium.click('css=a[user_count="search_t_inpt_gro"]')
        self._wait_load()


        all_links = BeautifulSoup(self.selenium.get_html_source()).findAll('a', 'btn_num')
        if all_links == []:
            _logger.debug('no group is found')
            return
        # go to random page
        for i in range(random.randint(1, 5)):
            soup = BeautifulSoup(self.selenium.get_html_source())
            all_links = soup.findAll('a', 'btn_num')
            link = random.choice(all_links)
            
            _logger.debug('clicking %s' % link.find('em', text=True))
            self.selenium.click('css=a[href="%s"]' % link['href'].encode('utf-8'))
            self._wait_load()

        soup = BeautifulSoup(self.selenium.get_html_source())
        link = random.choice(soup.findAll('a', 'btn_num'))

        # follow 5 of them
        all_groups = soup.findAll('a', 'addFollow')    
        for i in range(random.randrange(1, 8)):
            if all_groups == []:
                _logger.debug('not enough group to join')
            gp = random.choice(all_groups)
            all_groups.remove(gp)
            self.selenium.click('id=%s' % gp['id'])
            self.sleep_random(1, 2)
            _logger.debug('added group (%s)' % gp['id'])

    def fetch_tweet(self, source, item):
        return self.agent.fetch_tweet(source.id, item.id)

    def _crawl_tweet_internal(self, title_xpath, content_xpath, image_xpath, href_xpath, encoding, url):
        tweet = Tweet()
        # Parse href
        _logger.debug('getting href')
        href = ''
        if href_xpath != '':
            try:
                href = self._parse_xpath(href_xpath, attr='href')
                if href != '':
                    href = pbrowser.abs_url(url, href)
                    tweet.href = href.encode('utf-8')
                _logger.debug('href parsed as (%s)' % href)
            except Exception, err:
                _logger.error('failed to parse href:%s, url:(%s), xpath:(%s), will ommit href in tweet'
                              % (err, url, href_xpath))

        # Parse title
        _logger.debug('getting title')
        title = ''

        if title_xpath != '':
            try:
                title = self._parse_xpath(title_xpath)
                if title == None:
                    title = ''
                tweet.title = title.encode('utf-8')
                _logger.debug('title parsed as(%s)' % title.encode('utf-8'))
            except Exception, err:
                _logger.error('failed to parse title:%s, url:(%s), xpath:(%s), will ommit title in tweet'
                              % (err, url, title_xpath))

        # Parse content
        _logger.debug('getting content')
        content = ''
        if content_xpath != '':
            if content_xpath[0] == '&':
                content = content_xpath.decode('utf-8') # literal
            else:
                try:
                    content = self._parse_xpath(content_xpath)
                    _logger.debug('content originally parsed as (%s)' % content.encode('utf-8'))
                    # remove the tailing garbage
                    content = re.sub('\s{2,}\S+$', '', content)
                    content = pbrowser.html_unescape(content)
                    content = content.strip(u'.,，。 ')
                    content = re.sub('\s{2,}', ' ', content)
                    content = content.strip()
                    _logger.debug('content processed: (%s)' % content.encode('utf-8'))
                except Exception, err:
                    _logger.error('html_unescape failed:%s' % err)
        else:
            _logger.debug('content_xpath is None, will try extract from actual page')
            if href != '':
                content = pbrowser.extract_main_body(href, self.selenium, encoding = encoding)
            if content == '':
                _logger.debug('extracted nothing from actual page, empty content')
        content = content.strip(u'，。')
        _logger.debug('content parsed as(%s)' % content.encode('utf-8'))
        tweet.content = content.encode('utf-8')

        # Parse image
        image_url = ''
        image = None
        if href != '' and image_xpath != '':
            _logger.debug('getting image')
            # go into the original page and grab it
            _logger.debug('trying to grab the main image from original webpage, hint:(%s)' % tweet.title)
            try:
                image, image_url = pbrowser.get_main_image_with_hint(url = href,
                                                                     hint = title,
                                                                     hint_encoding = encoding)

                _logger.debug('image url: %s' % image_url)
            except Exception, err:
                _logger.error('failed to grab image from %s: %s,%s' % (href, err, traceback.format_exc()))
        else:
            _logger.debug('no image directive or no href to find image')

        tweet.image_bin = image
        if image_url != '':
            tweet.image_ext = os.path.splitext(image_url.encode('utf-8'))[1]
        else:
            tweet.image_ext = ''
        return tweet


    def crawl_item(self, source, item):
        self._prepare_webpage(source.base_url, source.encoding)
        tweet = self._crawl_tweet_internal(item.title, item.content, item.image, item.href,
                                  source.encoding, source.base_url)
        return tweet

    def crawl_source(self, source):
        _logger.debug('crawling source(%s)' % source.id)
        prime = False
        if hasattr(self, 'prime_crawl') and self.prime_crawl == True:
            if not source.is_prime:
                _logger.debug('ignoring non-prime source')
                return
            else:
                prime = True

        #crawl_pool = threadpool.ThreadPool(maxThreads = 10)

        try:
            terminate = 3 if prime else 1
            recursive_crawl(source.base_url, source.encoding, self.selenium, self.agent,
                            source.domain, terminate = terminate)
        except Exception, err:
            _logger.error('recursive_crawl  failed: %s, %s' % (err, traceback.format_exc()))

        # links = pbrowser.get_all_href(source.base_url, source.encoding)
        # _logger.debug("processing %d links" % (len(links)))
        # count = 0
        # now = datetime.now()
        # for idx, link in enumerate(links):
        #     last_crawled_at = self.agent.get_last_crawl_time(link['href'].encode('utf-8'))
        #     if (now - last_crawled_at).days <= 30:
        #         _logger.debug('ignore %s which is crawled %d days ago' % (link['href'], (last_crawled_at - now).days))
        #         continue

        #     tweet = None
        #     try:
        #         tweet = try_crawl_href(source, link, self.selenium)
        #     except Exception, err:
        #         _logger.error('crawl href failed: %s, %s' % (err, traceback.format_exc()))
        #         continue
        #     if tweet != None:
        #         count += 1
        #         try:
        #             self.agent.add_crawled_tweet(source, tweet)
        #             _logger.info('new tweed added to db, %d total, (%d / %d) prcessed' %
        #                          (count, idx, len(links)))
        #         except Exception, err:
        #             _logger.error('failed to add crawled tweet to DB: %s' % err)
        # _logger.debug('%d tweets crawled' % count)

            
    # Crawl tweet from source, find victims to follow
    def crawl_tweet(self, shard_id=0, shard_count=1):
        try:
            all_source = self.agent.get_all_source()
            round_start_time = datetime.now()
            for si, source in enumerate(all_source):
                # Ignore if the source
                # 1. Need query keyword
                # 2. Not in current shard
                # 3. Has lots of items unused
                if si % shard_count != shard_id:
                    continue
                start_time = datetime.now()

                try:
                    self.crawl_source(source)
                except Exception, err:
                    _logger.error('crawl source failed %s, %s' % (err, traceback.format_exc()))

                end_time = datetime.now()
                _logger.info('source crawled (%d/%d): source(%s), time elapsed:(%d)',
                              si, len(all_source),
                              source.id, (end_time - start_time).seconds)
            round_end_time = datetime.now()
            _logger.info('crawl tweet one round finished, time elapsed:(%s)',
                         (round_end_time -  round_start_time).seconds)
        except Exception, err:
            _logger.error('crawl tweet failed: %s, %s' % (err, traceback.format_exc()))

    def _find_victims_by_keyword(self, keyword):
        if type(keyword) == unicode:
            keyword = keyword.encode('utf-8')
        result = set()

        all_tweet = self.weibo.trends_statuses(trend_name=keyword)[:200]
        _logger.debug('%d tweet found for keyword %s' % (len(all_tweet), keyword))

        for tweet in all_tweet:
            victim_id = tweet.user.id
            if not self.agent.victim_crawled(self.user, victim_id) and \
                    not self.agent.exists_in_follow_log(self.user.uname, victim_id):
                result.add(victim_id)
        return result


    def get_victims_for_one_user(self):
        victims = set()

        for kw in self.user.victim_keywords:
            try:
                _logger.debug('finding victims by %s' % kw.encode('utf-8'))
                new_victims = set(self._find_victims_by_keyword(kw))
                _logger.info('(%d)new / (%d)found, victims for keyword (%s)',
                             len(new_victims - victims), len(new_victims),
                             kw.encode('utf-8'))
                victims.update(new_victims)
                self.sleep_random(1, 2)
                #For debugging
                if len(victims) > 100:
                    continue
            except WeibopError, err:
                _logger.error('got WeibopError(%s), quit for now, %s' % (err, traceback.format_exc()))
                break
            except Exception, err:
                _logger.error('finding victim failed, user: %s, keyword: (%s), error: %s, %s ',
                              self.user.uname, kw.encode('utf-8'), err, traceback.format_exc())
            
        return victims


    def crawl_victim(self, shard_id=0, shard_count=1):
        try:
            users = self.agent.get_all_user()
            round_start_time = datetime.now()
            for user in users:
                # Ignore if the user
                # 1. Not enabled
                # 2. Not in current shard
                # 3. Has lots of victims unused
                if not user.enabled or \
                        user.shard_id % shard_count != shard_id or \
                        self.agent.available_victim_num(user) > 200:
                    continue
                start_time = datetime.now()
                add_num = 0
                victims = []
                try:
                    self.assign_user(user)
                    _logger.debug("api generated for user(%s)" % self.user.uname)
                except WeibopError, err:
                    _logger.error('get_api_by_user failed: %s', err)
                except Exception, err:
                    _logger.error('get_api_by_user failed, but not WeibopError: %s', err)
                else:
                    _logger.info('getting victims for (%s)', self.user.uname)
                    try:
                        victims = self.get_victims_for_one_user()
                        add_num = self.agent.add_victims(self.user, victims)
                    except Exception, err:
                        _logger.error('crawl victim for (%s) failed: %s, %s' %
                                      (user.uname, err, traceback.format_exc()))
                        continue
                end_time = datetime.now()
                _logger.debug('added to DB: (%d)new/(%d)crawled  victims for user(%s), time elapsed: (%s)',
                              add_num, len(victims), self.user.uname,
                              (end_time -  start_time).seconds)
            round_end_time = datetime.now()
            _logger.info('crawl victim one round finished, time elapsed:(%s)',
                         (round_end_time -  round_start_time).seconds)
        except Exception, err:
            _logger.error('crawl victim failed: %s, %s' % (err, traceback.format_exc()))

    def crawl_tweet_daemon(self, shard_id=0, shard_count=1):
        while True:
            try:
                self.shard_id = shard_id
                self.shard_count = shard_count
                self.crawl_tweet(shard_id, shard_count)
                time.sleep(10)
            except KeyboardInterrupt, sigint:
                _logger.info('got SIGINT, will shutdown gracefully')
                self.shutdown()

    def crawl_victim_daemon(self, shard_id=0, shard_count=1):
        while True:
            try:
                self.shard_id = shard_id
                self.shard_count = shard_count
                self.crawl_victim(shard_id, shard_count)
                time.sleep(10)
            except KeyboardInterrupt, sigint:
                _logger.info('got SIGINT, will shutdown gracefully')
                self.shutdown()

    def assign_user(self, user):
        # choose proxy
        all_proxy = self.agent.get_all_proxy()
        if all_proxy == ():
            raise Exception('no proxy found, will use direct address')
        else:
            if not hasattr(self, 'shard_count'):
                self.shard_id = 0
                self.shard_count = 1
            proxy_candidate = [proxy for i, proxy in enumerate(all_proxy) 
                               if i % self.shard_count == self.shard_id]
            if len(proxy_candidate) == 0:
                raise Exception('not enough proxy')

            proxy = random.choice(proxy_candidate)
                
            os.environ['taras_proxy_addr'] = proxy['addr'].strip()
            os.environ['taras_proxy_port'] = str(proxy['port']).strip()
            os.environ['taras_proxy_user'] = proxy['user_name'].strip()
            os.environ['taras_proxy_passwd'] = proxy['password'].strip()
            _logger.debug('using proxy: %s' % os.environ['taras_proxy_addr'])
            self.agent.update_proxy_log(os.environ['taras_proxy_addr'],
                                        log_type="use")

        self.app = random.choice(self.agent.get_all_app())
        self.user = user

        _logger.debug('getting api')
        self.weibo = self.get_api_by_user(user.uname)

    def update_current_user_stat(self):
        try:
            stat = self.get_user_statistic(self.user, self.weibo)
            self.agent.update_db_statistic(stat)
        except Exception, err:
            _logger.error('update statistic failed: %s, %s'
                          % (err, traceback.format_exc()))

    # Post tweet, follow, comment
    def daemon(self, shard_id=0, shard_count=1):
        self.shard_id = shard_id
        self.shard_count = shard_count

        random.seed()

        round_count = 0
        current_day = datetime.now().day

        _logger.info('shard_id = %d, shard_count = %d' % (shard_id, shard_count))
        _logger.info('daemon started')

        try:
            while True:
                # parse config for what functions to run
                funcs = self.config.get('global', 'func_array')
                self.func_array = eval(funcs)
                _logger.info('func_array: %s' % (', '.join(map(lambda f: f.__name__, self.func_array))))

                # execute once a day
                self.once_func_array = eval(self.config.get('global', 'once_func_array'))
                _logger.info('once_func_array: %s' % (', '.join(map(lambda f: f.__name__, self.once_func_array))))


                if (datetime.now().day != current_day):
                    current_day = datetime.now().day
                    round_count = 1
                    _logger.info('first round today, reset round_count')
                else:
                    round_count += 1
                users = self.agent.get_all_user(shard_id, shard_count)
                user_num = len(users)
                _logger.info('will process %d users, round: %d' % (user_num, round_count))
                now = datetime.now()
                for index, user in enumerate(users):
                    # _logger.debug('got user (%s), shard_id=%d' %
                    #               (user.uname, user.shard_id))
                    if user.next_action_time < now:
                        if not user.enabled:
                            #_logger.debug('user (%s) disabled in DB' % user.uname)
                            continue
                        if user.shard_id % shard_count != shard_id:
                            #_logger.debug('this user(%s) is not no my shard' % user.uname)
                            continue
                        self.user = user
                        _logger.info("user(%s) in action, process: (%d / %d, round: %d)" % (user.uname, index, user_num, round_count))

                        start_time = datetime.now() # profiling

                        try:
                            _logger.debug('assigning user')
                            self.assign_user(user)
                            self.user.next_action_time = self._schedule_next_action()
                        except WeibopError, err:
                            _logger.error('get_api_by_user failed: %s, will freeze user', err)
                            self.freeze_user(user)
                        except Exception, err:
                            _logger.error('get_api_by_user failed, but not WeibopError: %s', err)
                        else:
                            _logger.debug("api generated for user(%s)" % self.user.uname)

                            self.agent.update_next_action_time(user, self.user.next_action_time)

                            for func in self.func_array:
                                try:
                                    func()
                                except Exception, err:
                                    _logger.error("func failed(%s), %s" % (err, traceback.format_exc()))

                        end_time = datetime.now() # profiling
                        _logger.info("profiled: %d seconds for %s" % ((end_time - start_time).seconds, self.user.uname))
                _logger.info('round %d finished' % round_count)
                time.sleep(10)
        except KeyboardInterrupt, sigint:
            _logger.info('got SIGINT, will shutdown gracefully')
            self.shutdown()

    def shutdown(self):
        if hasattr(self, 'selenium'):
            try:
                _logger.info('stopping Selenium client')            
                self.selenium.stop()
            except Exception, err:
                _logger.error('stopping Selenium client failed: %s' % err)

        try:
            _logger.info('stopping MySQL client')
            self.agent.stop()
        except Exception, err:
            _logger.error('stoping MySQL client failed: %s' % err)
        _logger.info('clean up finished, bye-bye')


    def sleep_random(self, low, high):
        sleep = random.randint(low, high)
        _logger.debug('randomly sleep for %d sec' % sleep)
        time.sleep(sleep)

    def _wait_load(self, minutes = 1):
        MIN = 60 * 1000
        try:
            self.selenium.wait_for_page_to_load(timeout = MIN * minutes)
        except Exception, err:
            _logger.error('error waiting page to load(%d min), will continue:%s' % (minutes, err))


    def get_user_statistic(self, user, api = None):
        if api == None:
            api = self.get_api_by_user(user.uname)
            me = api.me()
        else:
            me = self.weibo.me()
        # navigate to main page of 'user'

        stat = {
            'user': "%s#%s#%s#%s" % (me.name.encode('utf-8'), # nickname
                                     user.uname, # email for login
                                     user.passwd, # passwd
                                     self.get_user_url(user, api),
                                     ),
            'date': datetime.now().date().strftime("%Y-%m-%d"),
            'follow_count': me.friends_count,
            'followed_count': me.followers_count,
            'tweet_count': me.statuses_count,
            'mutual_follow_count': -1,
            }

        _logger.debug('status: follower:(%d), following:(%d), user:(%s)' % 
                      (stat['followed_count'], stat['follow_count'], stat['user']))
        return stat

    # This method is obsolating as for 2011-09-15, since we don't use selenium to login
    # to weibo anymore. Consider remove it.
    def get_peering_user(self, force=False):
        """
        Return a peering user. Peering user will be used for logging into sina weibo
        and finding victims from there.
        Since Sina may block IDs if they are used from one IP too frequently, we have 
        to stick on one ID for tasks such as crawling victims. Therefore this peering
        user thing
        """
        if not force and hasattr(self, 'peering_user') and self.peering_user_hit < 100:
            self.peering_user_hit += 1
            return self.peering_user

        _logger.info('getting peering user')

        all_user =  self.agent.get_all_user()

        user = None
        while True:
            user = random.choice(all_user)
            try:
                api = self.get_api_by_user(user.uname)
                _logger.info('selected new peering user:(%s, %s)' % (user.uname, api.me().name))
                break
            except Exception,err:
                _logger.error('get API failed for (%s): %s' % (user.uname, err))


        self.peering_user = user
        self.peering_user_hit = 0
        return self.get_peering_user()


    def get_api_on_the_fly(self, uname, passwd):
        app = random.choice(self.agent.get_all_app())
        token = self.authorize_app(uname, passwd, app)
        handle = sina_auth.OAuthHandler(app.consumer_key, app.consumer_secret)
        handle.setToken(token=token.key, tokenSecret=token.secret)
        return sina_api(handle)


    def get_user_url(self, user, api=None):
        """
        Given an Email address, return the user's weibo profile page URL
        """
        if api == None:
            api = self.get_api_by_user(user.uname)
        return "http://weibo.com/%s" % str(api.me().id)


    def create_tweet_on_the_fly(self, url, title, content, href, image, encoding):
        """
        Create a tweet using supplied URL and Xpath elements
        """
        self._prepare_webpage(url, encoding)
        return self._create_fresh_tweet(title, content, image, href, encoding, url)

    def create_random_tweet(self):
        """
        Like create_tweet_on_the_fly(), but with no URL and XPath. Will pick up
        a source from DB
        """
        source = self.agent.get_random_source()
        return self.create_tweet(source, u'热门')

    def handle_int(self, signum, frame):
        _logger.info('got signal(%d), will shutdown gracefully' % signum)
        self.shutdown()
        sys.exit(0)

    # For testing only
    def give_us_an_api(self, dbname='taras', dbuser='taras', dbpass='admin123'):
        random.seed()
        self.agent = SQLAgent(dbname, dbuser, dbpass)
        user = random.choice(self.agent.get_all_user())
        app = random.choice(self.agent.get_all_app())
        token = self.get_token(user, app)
        handle = sina_auth.OAuthHandler(app.consumer_key, app.consumer_secret)
        handle.setToken(token=token.key, tokenSecret=token.secret)
        print "using user(%s), app(%s)" % (user.uname, app.id)
        return sina_api(handle)

    # Carry on various functions on the user specified by 'email'
    def test_on_user(self, email):
        user = self.agent.get_user_by_email(email)
        self.assign_user(user)
        func_array=[self.post_tweet, self.retweet]
        for func in func_array:
            try:
                func()
            except Exception, err:
                _logger.error('func() failed, %s, %s' % (err, traceback.format_exc()))
    
    def sync_follow_log(self, email):
        user = self.agent.get_user_by_email(email)
        self.assign_user(user)
        cursor = 0
        while True:
            friends = self.weibo.friends(count = 200, cursor = cursor)
            if len(friends) == 0:
                break
            cursor = len(friends) + cursor
            for f in friends:
                self.agent.add_follow_log(email, f.name.encode('utf-8'))
                _logger.debug('add to log, email: %s, nick:(%s)'
                              % (email, f.name.encode('utf-8')))

def usage():
    print """
             Usage: taras.py -u(--user=) DB-USER -p(--passwd=) DB-PASSWORD -d(--database=) DB-NAME
             [-s(--shard) SLICE_ID -a(--all-shard) SLICE_COUNT]
             [-c(--command) COMMAND]
          """
    sys.exit(2)

if __name__ == "__main__":
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
    command = 'daemon'
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
    elif command == 'prime-crawl':
        noselenium = False
        daemon = WeiboDaemon(dbname, dbuser, dbpass, noselenium = noselenium)
        signal.signal(signal.SIGINT, daemon.handle_int)
        daemon.prime_crawl = True
        daemon.crawl_tweet_daemon(shard_id, shard_count)
    elif command == 'index-tweet':
        import tindexer
        indexer = tindexer.TIndexer()
        indexer.start_indexer_daemon(dbname, dbuser, dbpass)
    else:
        _logger.error('unknown command: (%s)' % command)
        usage()
