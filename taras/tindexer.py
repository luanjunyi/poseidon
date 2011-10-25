import os, sys, re, random, cPickle, traceback, urllib, time, signal
from datetime import datetime, timedelta

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root

from sql_agent import Tweet, SQLAgent
from util.log import _logger
from util import pbrowser, util

class TIndexer:
    def build_keyword_user_index(self, users):
        index = {}
        for user in users:
            for keyword in user.tags:
                if type(keyword) == unicode:
                    keyword = keyword.encode('utf-8')
                if keyword in index:
                    index[keyword].append(user)
                else:
                    index[keyword] = [user]
        return index

    def indexer_process(self, users, tweets):
        # build keyword -> user-list index
        for idx, tweet in enumerate(tweets):
            for user in users:
                count = 0
                for poison in user.poison_tags:
                    poison = poison.encode('utf-8')
                    if tweet.title.count(poison)  + tweet.content.count(poison) > 0:
                        continue
                for tag in user.tags:
                    tag = tag.encode('utf-8')
                    count += tweet.title.count(tag) * 2 + tweet.content.count(tag)
                if count >= 5:
                    try:
                        self.agent.push_tweet_stack(user.uname, tweet.db_id)
                        _logger.debug('tweet(title=%s) add for user(%s) count = %d' % 
                                      (tweet.title, user.uname, count))
                    except Exception, err:
                        _logger.error('failed to push tweet stack tweet id=%d, user=%s: %s'
                                      % (tweet.db_id, user.uname, err))
                        print traceback.format_exc()
            if (idx % 100 == 0):
                _logger.info('%d / %d tweet processed' % (idx, len(tweets)))


    def indexer_loop(self):
        # process indexed user and unindexed tweet
        users = self.agent.get_all_user_indexed()
        tweets = self.agent.get_unindexed_tweets()
        _logger.debug('processing %d unindexed tweet and %d indexed users' % 
                      (len(tweets), len(users)))
        if len(users) > 0 and len(tweets) > 0:
            self.indexer_process(users, tweets)
            for tweet in tweets:
                try:
                    self.agent.mark_tweet_as_indexed(tweet.db_id)
                    _logger.debug('raw_tweet(id=%d) indexed' % tweet.db_id)
                except Exception, err:
                    _logger.error('failed mark raw tweet as indexed, id=%d: %s'
                                  % (tweet.db_id, err))

        _logger.info('indexed user V.S. unindexed tweet processed')

        # process unindexed user with all tweet

        users = self.agent.get_all_user_not_indexed()
        tweets = self.agent.get_all_tweet_crawled(since=datetime.now() + timedelta(days=-14))
        _logger.debug('process %d unindexed user and %d tweets(all)' %
                      (len(users), len(tweets)))
        if len(users) > 0 and len(tweets) > 0:
            self.indexer_process(users, tweets)
            for user in users:
                try:
                    self.agent.mark_user_as_indexed(user.uname)
                except Exception, err:
                    _logger.error('failed mark user as indexed, email=%s: %s'
                                  % (user.uname, err))
            
        _logger.info('unindexed user V.S. all tweet processed')


    def handle_int(self, signum, frame):
        _logger.info('got signal(%d), will shutdown SQLAgent gracefully' % signum)
        self.agent.stop()
        sys.exit(0)
                

    def start_indexer_daemon(self, dbname, dbuser, dbpass):
        signal.signal(signal.SIGINT, self.handle_int)
        _logger.info('starting indexer, DB: (%s@%s:%s)' % (dbuser, dbname, dbpass))
        while True:
            try:
                self.agent = SQLAgent(dbname, dbuser, dbpass, sscursor=True)
                _logger.info('SQLAgent initialized')
                self.indexer_loop()

                self.agent.stop()
            except KeyboardInterrupt, sigint:
                _logger.info('got Keyboard interuption, will shutdown SQLAgent gracefully')
                self.agent.stop()
            except Exception, err:
                _logger.error('indexer_loop failed: %s, %s' % (err, traceback.format_exc()))

            _logger.info('sleeping for 60 sec')
            time.sleep(60)
            break

def usage():
    print """
             Usage: tindexer.py -u(--user=) DB-USER -p(--passwd=) DB-PASSWORD -d(--database=) DB-NAME
          """
    sys.exit(1)

if __name__ == "__main__":
    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'hu:p:d:', ['help', 'user=', 'passwd=', 'database='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()

    usage_only = False
    dbname = 'taras'
    dbuser = 'taras'
    dbpass = 'admin123'

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage_only = True
        if opt in ('-u', '--user'):
            dbuser = arg
        if opt in ('-p', '--passwd'):
            dbpass = arg
        if opt in ('-d', '--database'):
            dbname = arg

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

    indexer = TIndexer()
    indexer.start_indexer_daemon(dbname, dbuser, dbpass)

