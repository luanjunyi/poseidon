# This module is all about dealing with MYSQL DB for Taras or related modules
# Caveat:
# auto-commit is disabled by defaut per some API standard. Therefore we must add
# commit explicitly on every 'write' SQL command. Otherwise, as implied by some ducument,
# no change can take effect for innodb engine

import sys, os, cPickle, random, hashlib
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root
from datetime import datetime
from util.log import _logger
from third_party import chardet
import MySQLdb

class Tweet:
    def __init__(self, title='', content='', href='', image_ext='', image_bin=None):
        self.title = title
        self.content =content
        self.href = href
        self.image_ext = image_ext
        self.image_bin = image_bin
        self.db_id = 'not set'

class Source:
    def __init__(self, source, items = []):
        self.id = source['id']
        self.base_url = source['base_url']
        self.encoding = source['encoding']
        self.need_query = (source['need_query'] == 1)
        self.items = []
        self.is_prime = (source['is_prime'] == 1)
        self.domain = source['domain']
        for item in items:
            self.items.append(SourceItem(item))

class SourceItem:
    def __init__(self, item):
        self.title = item['title_xpath']
        self.content = item['content_xpath']
        self.image = str(item['image_xpath'])
        self.href = item['href_xpath']
        self.id = item['id']

class UserAccount:
    def _split_by_sharp(self, value):
        if value == None:
            return []

        items = filter(lambda i: len(i) > 0, value.split('#'))
        return map(lambda i: i.decode('utf-8').strip(), items)

    def __init__(self, user):
        """
        Initialize user from DB. 
        """
        self.uname = user['email']
        self.passwd = user['passwd']

        self.tags = self._split_by_sharp(user['tags'])
        self.poison_tags = self._split_by_sharp(user['poison_tags'])
        self.victim_keywords = self._split_by_sharp(user['victim_keywords'])
        self.sources = self._split_by_sharp(user['sources'])
        self.categories = self._split_by_sharp(user['categories'])

        self.start_time = user['work_time_start']
        self.end_time = user['work_time_end']
        if user['next_action_time'] != -1:
            self.next_action_time = datetime.fromtimestamp(user['next_action_time'])
        else:
            self.next_action_time = datetime.now()

        if user.has_key('sina_id'):
            self.sina_id = user['sina_id']
        else:
            self.sina_id = 0
        self.enabled = (user['enabled'] == 1)

        self.shard_id = user['id']
        self.freeze_to = user['freeze_to']
                

class RaceUserAccount:
    """
    This class is for Taras race only. So far, at least.
    """
    def __init__(self, user):
        self.owner = user['player_id'];
        self.uname = user['account'];
        self.passwd = user['passwd']

class AppAccount:
    def __init__(self, app):
        self.id = app['id']
        self.consumer_key = app['token']
        self.consumer_secret = app['secret']

class ForceAction:
    def __init__(self, fa):
        self.type = fa['type']
        self.value = fa['value']
        categories = filter(lambda i: len(i) > 0, fa['affected_categories'].split('#'))
        self.categories = map(lambda i: i.decode('utf-8'), categories)

class SQLAgent:
    # set sscursor to True if want to store the result set in server. It's for large result set
    def __init__(self, db_name, db_user, db_pass, host = "localhost", sscursor = False):
        self.db_name = db_name
        self.db_user = db_user
        self.db_pass = db_pass

        _logger.info('connecting DB... host:%s %s@%s:%s' % (host, db_user, db_name, db_pass))
        self.conn = MySQLdb.connect(host = host,
                                    user = self.db_user,
                                    passwd = self.db_pass,
                                    db = self.db_name,
                                    )
        if sscursor: # store result in server
            self.cursor = self.conn.cursor(MySQLdb.cursors.SSDictCursor)
        else:
            self.cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)

        self.cursor.execute('set names utf8')
        self.conn.commit()

    def stop(self):
        self.cursor.close()
        self.conn.close()

    def update_user_keywords(self, user):
        self.cursor.execute('delete from user_keyword_index where email = %s', user.uname)
        for keyword in user.categories:
            self.cursor.execute('insert into user_keyword_index(email, keyword) values(%s, %s)',
                                (user.uname, keyword.encode('utf-8')))
        self.conn.commit()

    def get_all_user_internal(self, raw_users):
        users = [UserAccount(user) for user in raw_users]
        random.shuffle(users)
        return users

    def get_all_user(self, shard_id = 0, shard_count = 1):
        """
        Get all enabled, non-frozen users from DB
        Side-effect: release frozen user if freeze_to date is passed
        """
        self.cursor.execute('select * from sina_user where enabled = 1 and id %% %d = %d' %
                            (shard_count, shard_id))
        raw_users = self.cursor.fetchall()
        return self.get_all_user_internal(raw_users)

    def get_all_user_including_disabled(self, shard_id = 0, shard_count = 1):
        self.cursor.execute('select * from sina_user where id %% %d = %d' %
                            (shard_count, shard_id))
        raw_users = self.cursor.fetchall()
        return self.get_all_user_internal(raw_users)

    def get_user_by_email(self, email):
        self.cursor.execute('select * from sina_user where email = %s', email)
        if self.cursor.rowcount == 0:
            return None
        return UserAccount(self.cursor.fetchone())


    def disable_user(self, email):
        self.cursor.execute('update sina_user set enabled = 0 where email = %s',
                            email)
        self.conn.commit()

    def freeze_user(self, user, freeze_to):
        self.cursor.execute('update sina_user set freeze_to = %s where email = %s',
                            (freeze_to, user.uname))
        self.conn.commit()

    def warm_user(self, user):
        self.cursor.execute('update sina_user set freeze_to = NULL where email = %s',
                            (user.uname))
        self.conn.commit()


    def get_all_app(self):
        self.cursor.execute('select * from sina_app')
        apps = self.cursor.fetchall()
        return [AppAccount(app) for app in apps]
        
    def get_token(self, user_email, app_id):
        self.cursor.execute("select value from sina_token where user_email = %s and app_id = %s",
                            (user_email, app_id))
        if self.cursor.rowcount == 0:
            return None
        r = self.cursor.fetchone()
        return r['value']

    def update_token(self, user_email, app_id, value):
        try:
            self.cursor.execute("insert into sina_token values(%s, %s, %s)",
                                (user_email, app_id, value))
            self.conn.commit()
            return True
        except Exception, err:
            _logger.error("failed to update new token using insert:%s, will try update" % err)
        try:
            self.cursor.execute("update sina_token set value=%s where user_email=%s and app_id=%s",
                                (value, user_email, app_id))
            self.conn.commit()
            return True
        except Exception, err:
            _logger.error("failed to update token using update:%s, will give up" % err)
            return False

    def get_all_source(self):
        self.cursor.execute('select id from source')
        source_ids = self.cursor.fetchall()
        return [self.get_source(i['id']) for i in source_ids]

    def get_source(self, source_id):
        self.cursor.execute("select * from source where id=%s", source_id)
        if (self.cursor.rowcount != 1):
            raise Exception("can't fetch source, id:(%s)" % source_id)
        source = self.cursor.fetchone()
        self.cursor.execute("select * from source_item where source_id = %s",
                            source_id)
        items = self.cursor.fetchall()
        return Source(source, items)

    def get_random_source(self):
        self.cursor.execute("select * from source")
        if (self.cursor.rowcount < 1):
            raise Exception("No source in DB")
        source = random.choice(self.cursor.fetchall())
        self.cursor.execute("select * from source_item where source_id = %s",
                            source['id'])
        items = self.cursor.fetchall()
        return Source(source, items)

    def get_source_by_tag(self, tag):
        tag = tag.replace('|', '\\|')
        self.cursor.execute('select * from source where tags regexp %s',
                            '^%(tag)s#|#%(tag)s#|#%(tag)s$|^%(tag)s$' % {'tag': tag})
        all_source = self.cursor.fetchall()
        if len(all_source) > 0:
            source = random.choice(all_source)
            self.cursor.execute("select * from source_item where source_id = %s",
                                source['id'])
            items = self.cursor.fetchall()
            return Source(source, items)
        else:
            return None

    def add_follow_log(self, email, victim):
        if not self.exists_in_follow_log(email, victim):
            self.cursor.execute('insert into follow_log values(%s, %s)',
                                (email, victim))
            self.conn.commit()

    def exists_in_follow_log(self, email, victim):
        self.cursor.execute('select count(*) as count from follow_log where email = %s and victim = %s',
                            (email, victim))
        return self.cursor.fetchone()['count'] > 0

        

    def get_random_source_item(self, source_id):
        random.seed()
        self.cursor.execute("select * from source_item where source_id = %s",
                            source_id)
        items = self.cursor.fetchall()
        return SourceItem(random.choice(items))
        

    def add_comment_request(self, tweet_id, content, user_email):
        self.cursor.execute('insert comment_request(tweet_id, content, user_email) values(%s, %s, %s)',
                            (tweet_id, content, user_email))
        self.conn.commit()

    def add_tweet_log(self, content, email):
        self.cursor.execute('insert tweet_published(content, user_email) values(%s, %s)',
                            (content, email))
        self.conn.commit()

    def get_tweet_log(self, email):
        self.cursor.execute('select content from tweet_published where user_email = %s order by id desc limit 200',
                            email)
        items = self.cursor.fetchall()
        return [item['content'] for item in items]

    def add_tweet_source(self, sourceid, base_url, encoding, cmd=""):
        self.cursor.execute('insert source(id, soup_cmd, base_url, encoding) values(%s, %s, %s, %s)',
                            (sourceid, cmd, base_url, encoding))
        self.conn.commit()

    def update_next_action_time(self, user, next_time):
        import time
        self.cursor.execute('update sina_user set next_action_time = %s where email = %s',
                            (time.mktime(next_time.timetuple()), user.uname))
        self.conn.commit()

    def update_follow_date(self, user, followee_id, create_date):

        self.cursor.execute('insert follow_date values(%s, %s, %s)',
                            (user.uname, followee_id, cPickle.dumps(create_date)))
        self.conn.commit()

    def stop_follow(self, user, followee_id):
        try:
            self.cursor.execute('delete from follow_date where user_email = %s and followee_id = %s',
                                (user.uname, followee_id))
            self.conn.commit()
        except Exception, err:
            _logger.error('failed deleting follow date, user:(%s), followee_id:(%s), error:(%s)' %
                          (user.uname, followee_id, err))

    def get_follow_date(self, user, followee_id):
        self.cursor.execute('select create_date from follow_date where user_email = %s and followee_id = %s',
                            (user.uname, followee_id))
        if self.cursor.rowcount == 0:
            return None
        date = self.cursor.fetchone()['create_date']
        return cPickle.loads(date)

    def get_followee_count(self, user):
        self.cursor.execute('select create_date from follow_date where user_email = %s', (user.uname))
        return self.cursor.rowcount

    def get_random_comment(self):
        self.cursor.execute('select content from random_comment')
        if self.cursor.rowcount == 0:
            raise Exception('random comment table is empty')
        comment = random.choice(map(lambda i: i['content'], self.cursor.fetchall()))

        self.cursor.execute('select content from random_follow_request')
        if self.cursor.rowcount == 0:
            raise Exception('random_follow_request table is empty')
        return comment + ' ' + random.choice(map(lambda i: i['content'], self.cursor.fetchall()))


    def update_sina_id(self, user):
        self.cursor.execute('update sina_user set sina_id = %s where email = %s',
                            (user.sina_id, user.uname))
        self.conn.commit()

    def get_all_force_action(self):
        self.cursor.execute('select * from force_action')
        actions = self.cursor.fetchall()
        return [ForceAction(action) for action in actions]

    # About user statistics
    def update_db_statistic(self, stat):
        self.cursor.execute(
            "replace user_statistic values(%s, %s, %s, %s, %s, %s)",
            (stat['user'], stat['date'], stat['follow_count'],
             stat['followed_count'], stat['tweet_count'], stat['mutual_follow_count']))

    def get_last_action_time(self, user):
        self.cursor.execute("select collect_date from user_statistic where user like '%%%s%%' order by collect_date desc limit 1"
                            % user.uname)
        if self.cursor.rowcount == 0:
            return None
        return datetime.strptime(self.cursor.fetchone()['collect_date'], '%Y-%m-%d')
        

    def get_safe_source(self):
        return self.get_source('safe.news.baidu')

    # Tweet DB management
    def get_all_tweet_crawled(self):
        self.cursor.execute('select * from tweet_crawled')
        tweets = []
        for raw_tweet in self.cursor.fetchall():
            t = Tweet(title = raw_tweet['title'],
                      content = raw_tweet['content'],
                      href= raw_tweet['href'],
                      image_ext = raw_tweet['image_ext'],
                      image_bin = raw_tweet['image_bin'])
            t.db_id = raw_tweet['id']
            tweets.append(t)
        return tweets


    def add_crawled_tweet(self, base_url, tweet):
        self.cursor.execute('replace into tweet_crawled(source, title, content, href,\
image_bin, image_ext, href_md5) values(%s, %s, %s, %s, %s, %s, %s)',
                            (base_url,
                             tweet.title, tweet.content, tweet.href,
                             tweet.image_bin, tweet.image_ext,
                             hashlib.md5(tweet.href).hexdigest()))
        if self.cursor.rowcount != 1:
            raise Exception('%d rows inserted' % self.cursor.rowcount)
        self.conn.commit()

    def fetch_tweet(self, source_id, item_id):
        self.cursor.execute('select * from tweet_crawled where source = %s and item = %s',
                            (source_id, item_id))
        if self.cursor.rowcount == 0:
            return None
        else:
            tweet = self.cursor.fetchone()
            return Tweet(tweet['title'], tweet['content'], tweet['href'], image_ext=tweet['image_ext'], image_bin=tweet['image_bin'])

    def get_unindexed_tweets(self):
        self.cursor.execute('select * from tweet_crawled where indexed = 0')
        tweets = []

        for raw_tweet in self.cursor.fetchall():
            t = Tweet(title = raw_tweet['title'],
                      content = raw_tweet['content'],
                      href= raw_tweet['href'],
                      image_ext = raw_tweet['image_ext'],
                      image_bin = raw_tweet['image_bin'])
            t.db_id = raw_tweet['id']
            tweets.append(t)
        return tweets

    def mark_tweet_as_indexed(self, tweet_id):
        self.cursor.execute('update tweet_crawled set indexed = 1 where id = %s', tweet_id)
        if self.cursor.rowcount != 1:
            raise Exception('failed to mark tweet(id=%d) as indexed, %d rows affected'
                            % (tweet_id, self.cursor.rowcount))
        self.conn.commit()

    def get_all_user_indexed(self, shard_id = 0, shard_count = 1):
        """
        Get all enabled, indexed users from DB
        """
        self.cursor.execute('select * from sina_user where enabled = 1 and indexed = 1 and id %% %d = %d' %
                            (shard_count, shard_id))
        raw_users = self.cursor.fetchall()
        return self.get_all_user_internal(raw_users)

    def get_all_user_not_indexed(self, shard_id = 0, shard_count = 1):
        """
        Get all enabled, indexed users from DB
        """
        self.cursor.execute('select * from sina_user where enabled = 1 and indexed = 0 and id %% %d = %d' %
                            (shard_count, shard_id))
        raw_users = self.cursor.fetchall()
        return self.get_all_user_internal(raw_users)

    def mark_user_as_indexed(self, user_email):
        self.cursor.execute('update sina_user set indexed = 1 where email = %s', user_email)
        self.conn.commit()



    def is_tweet_stack_empty(self, email):
        self.cursor.execute('select user_email from tweet_stack where user_email = %s', email)
        return self.cursor.rowcount == 0
        

    def push_tweet_stack(self, email, tweet_id):
        self.cursor.execute('replace into tweet_stack(user_email, tweet_id) values(%s, %s)',
                            (email, tweet_id))
        self.conn.commit()

    def pop_tweet_stack(self, email):
        self.cursor.execute('select tweet_id from tweet_stack where user_email = %s order by tweet_id desc',
                            email)
        if self.cursor.rowcount == 0:
            _logger.debug('failed to pop tweet stack, it\'s empty, email=%s' % email)
            return None

        all_rows = self.cursor.fetchall()
        for cur_row in all_rows:
            tweet_id = cur_row['tweet_id']
            self.cursor.execute('delete from tweet_stack where tweet_id = %s', tweet_id)
            self.conn.commit()
            _logger.debug('tweet stack popped, it=%d' % tweet_id)

            self.cursor.execute('select * from tweet_crawled where id = %s', tweet_id)
            if self.cursor.rowcount == 0:
                _logger.debug('failed to find corresponding raw tweet with id = %s' % tweet_id)
                continue
            raw_tweet = self.cursor.fetchone()
            t = Tweet(title = raw_tweet['title'],
                      content = raw_tweet['content'],
                      href= raw_tweet['href'],
                      image_ext = raw_tweet['image_ext'],
                      image_bin = raw_tweet['image_bin'])

            return t

        _logger.debug('all tweet in stack tried, none ID found in DB')
        return None

        

    def remove_tweet(self, source_id, item_id):
        self.cursor.execute('delete from tweet_crawled where \
source = %s and item = %s', (source_id, item_id))
        self.conn.commit()

    def get_last_crawl_time(self, href):
        md5 = hashlib.md5(href).hexdigest()
        self.cursor.execute('select created_at from tweet_crawled where href_md5 = %s',
                            (md5))
        if self.cursor.rowcount == 0:
            return datetime(1970,1,1) # as if we crawled it decades ago
        return self.cursor.fetchone()['created_at']

    def get_last_crawl_time_by_title(self, title):
        self.cursor.execute('select created_at from tweet_crawled where title = %s',
                            (title))
        if self.cursor.rowcount == 0:
            return datetime(1970,1,1) # as if we crawled it decades ago
        return self.cursor.fetchone()['created_at']

    # crawl history for individual source
    def update_crawl_history(self, source_url):
        self.cursor.execute('replace crawl_history(source) value(%s)', source_url)
        self.conn.commit()

    def get_crawl_history(self, source_url):
        self.cursor.execute('select last_crawl from crawl_history where source = %s', source_url)
        if self.cursor.rowcount == 0:
            return datetime(1970,1,1)
        return self.cursor.fetchone()['last_crawl']

    def available_tweet_num(self, source):
        self.cursor.execute('select count(source) as count from tweet_crawled where source = %s',
                            (source.id))
        return self.cursor.fetchone()['count']

    # Victim DB management        
    def available_victim_num(self, user):
        self.cursor.execute('select count(email) as count from victim_crawled where email = %s',
                            (user.uname))
        return self.cursor.fetchone()['count']

    def add_victims(self, user, victims):
        if len(victims) == 0:
            return 0

        value_str = ''
        for index, victim in enumerate(victims):
            if index == 0:
                value_str += '("%s", "%d")' % (user.uname, victim)
            else:
                value_str += ', ("%s", "%d")' % (user.uname, victim)
        sql = 'insert ignore victim_crawled values %s' %  value_str
        self.cursor.execute(sql)
        return self.cursor.rowcount

    def remove_victim(self, user, victim):
        self.cursor.execute('delete from victim_crawled where email = %s \
and victim = %s', (user.uname, str(victim)))
        self.conn.commit()

    def victim_crawled(self, user, victim):
        """return True if the (user,victim) pair is already in DB"""
        self.cursor.execute('select count(*) as count from victim_crawled \
where email = %s and victim = %s', (user.uname, str(victim)))
        return self.cursor.fetchone()['count'] > 0

    def get_victims(self, user, count):
        self.cursor.execute('select victim from victim_crawled where \
email = %s limit %s', (user.uname, count))
        return [int(result['victim']) for result in self.cursor.fetchall()]

    def get_random_victim(self, user):
        self.cursor.execute('select victim from victim_crawled where \
email = %s', (user.uname))
        if self.cursor.rowcount == 0:
            return None
        return int(self.cursor.fetchone()['victim'])

    # This method assume DB is for Taras race and contain tables required.
    def get_all_account_in_race(self):
        self.cursor.execute('select * from owner')
        users = self.cursor.fetchall()
        return [RaceUserAccount(user) for user in users]


    # Clean stubborn log
    def is_stubborn_cleaned(self, email, date):
        self.cursor.execute('select * from clean_followee_log where email = %s and date = %s',
                            (email, date))
        return self.cursor.rowcount > 0

    def mark_stubborn_cleaned(self, email, date):
        self.cursor.execute('replace into clean_followee_log(email, date) values(%s, %s)',
                            (email, date))
        self.conn.commit()

    # Proxy
    def get_random_proxy(self):
        self.cursor.execute('select * from proxy')
        if self.cursor.rowcount == 0:
            _logger.error('no proxy in DB')
            return None
        all_proxy = list(self.cursor.fetchall())
        all_proxy.append(None) # simulate direct access as one proxy
        
        return random.choice(all_proxy)

    def get_all_proxy(self):
        self.cursor.execute('select * from proxy')
        if self.cursor.rowcount == 0:
            _logger.error('no proxy in DB')
            return ()
        return self.cursor.fetchall()
        
    def update_proxy_status(self, proxy_id, ok_rate, avg_time):
        self.cursor.execute('insert into proxy_status(proxy_id, ok_rate, avg_time)  values(%s, %s, %s)',
                            (proxy_id, ok_rate, avg_time))
        self.conn.commit()
