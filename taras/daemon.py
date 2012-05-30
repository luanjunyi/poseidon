LOOP_INTERVEL = 60
TWEET_DB_NAME = 'weDaily'
TWEET_DB_USER = 'junyi'
TWEET_DB_PASS = 'admin123'
TWEET_DB_HOST = 'grampro.com'

import eventlet
eventlet.monkey_patch()
import os, sys, time, traceback, datetime, socket

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + './../') # Poseidon root

import sql_agent
import ios.weDaily.backend.db

from taras_func import Taras


import api_adapter
from util.log import _logger

socket.setdefaulttimeout(120)

tweet_agent = ios.weDaily.backend.db.init(TWEET_DB_NAME,
                                          TWEET_DB_USER,
                                          TWEET_DB_PASS,
                                          TWEET_DB_HOST)

def index_tweet(agent, user):
    taras = Taras(api_type, agent)
    try:
        taras.assign_user(user)
        taras.find_tweet(tweet_agent)
    except Exception, err:
        _logger.error("failed user(%d) indexing tweet: %s" % (user.id, traceback.format_exc()))
    else:
        _logger.debug("user(%d) finished indexing tweet" % user.id)

def crawl_victim(agent, user):
    taras = Taras(api_type, agent)
    try:
        taras.assign_user(user) 
        taras.crawl_victim()
    except Exception, err:
        _logger.error("failed user(%d) crawling victims: %s" % (user.id, err))
    else:
        _logger.debug("user(%d) finished crawling victims" % user.id)

def perform_routine(agent, user):
    taras = Taras(api_type, agent)
    try:
        taras.assign_user(user) 
    except Exception, err:
        _logger.error('assigning user(%d) failed:%s' % (user.id, traceback.format_exc()))
        agent.user_auth_fail.add({'user_id': user.id,
                                  'fail_time': str(datetime.datetime.now())})
        return
    try:
        _logger.debug("will start routine for user(%d)" % user.id)
        taras.routine()
    except Exception, err:
        _logger.error("failed user(%d) routine: %s" % (user.id, traceback.format_exc()))
    else:
        _logger.debug("user(%d) finished routine" % user.id)


def action(dbuser, dbpass, dbname, dbhost, api_type, action_func):
    agent = sql_agent.init(dbname, dbuser, dbpass, dbhost)

    agent.start()
    pool = eventlet.GreenPool()
    loop_id = 1
    while True:
        try:
            all_user = agent.get_all_user()
            for user in all_user:
                if user.id != 8684:
                    continue
                _logger.debug("user(%d) added to pool" % user.id)
                pool.spawn(action_func, agent, user)
            _logger.info("waiting for all user to finish")
            pool.waitall()
            _logger.info('#%d action loop finished, will sleep for %d' % (loop_id, LOOP_INTERVEL))
            loop_id += 1
            time.sleep(LOOP_INTERVEL)
        except Exception, err:
            _logger.error('action loop failed once:%s', traceback.format_exc())
        except KeyboardInterrupt, err:
            _logger.info('got SIGINT, will stop daemon')
            break
    agent.stop()

def usage():
    print """
             Usage: daemon.py [-h(--db-host=) DB-HOSTNAME] -u(--user=) DB-USER -p(--passwd=) DB-PASSWORD -d(--database=) DB-NAME
             -c(--command) COMMAND -t(--type) API-TYPE
             [-h(--help)]
          """
    sys.exit(2)

if __name__ == "__main__":
    actions = {'crawl_victim': crawl_victim,
               'index_tweet': index_tweet,
               'routine': perform_routine}

    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'hs:u:p:d:c:t:', ['help', 'db-host=', 'user=', 'passwd=', 'database=', 'command=', 'type='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()

    usage_only = False
    dbhost = 'localhost'
    dbname = 'taras_qq'
    dbuser = 'junyi'
    dbpass = 'admin123'
    shard_id = 0
    shard_count = 1
    command = 'unset'
    api_type = None
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage_only = True
        if opt in ('-s', '--db-host'):
            dbhost = arg
        if opt in ('-u', '--user'):
            dbuser = arg
        if opt in ('-p', '--passwd'):
            dbpass = arg
        if opt in ('-d', '--database'):
            dbname = arg
        if opt in ('-c', '--command'):
            command = arg
        if opt in ('-t', '--type'):
            api_type = arg

    if usage_only:
        usage()

    if api_type == None:
        print '-t(--type=) must be provided'
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

    _logger.info('db-host:%s db-user:%s, db-pass:%s, db-name:%s, command = (%s), api-type=%s' % 
                 (dbhost, dbuser, dbpass, dbname, command, api_type))

    if command == 'index_tweet':
        tweet_agent.start()

    if command not in actions:
        _logger.error("unknown command:(%s)" % command)
        usage()
    else:
        action(dbuser, dbpass, dbname, dbhost, api_type, actions[command])
