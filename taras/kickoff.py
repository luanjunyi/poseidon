#! /usr/bin/python
# -*- coding: utf-8 -*-
import sys, traceback, random, time
import taras
from util.log import _logger

def usage():
    print 'usage: update_statistic -u[USER=tarse] -d[DB=taras] -p[PASSWD=admin123]'
    sys.exit(0)

def fill_account(daemon, helper, user):

    sele = daemon.selenium
    daemon.user = user
    _logger.info('start joining groups')
    try:
        daemon.grouping(force=True)
    except Exception, err:
        _logger.error('grouping failed: %s' % err)
    _logger.info('start random posting')
    daemon._login_sina_weibo(user)
    for i in range(random.randrange(8,12)):
        retry = 0
        while retry < 5:
            try:
                tweet_text, tweet_img = helper.create_random_tweet()
                break
            except Exception, err:
                _logger.error('generating tweet failed once(%d/5): %s' % (retry + 1, err))
                retry += 1
        _logger.debug('publishing (%s)' % tweet_text)
        sele.type('id=publish_editor', tweet_text.decode('utf-8'))
        sele.click('id=publisher_submit')
        daemon.sleep_random(1, 10)
    _logger.debug('user (%s) filled up' % user.uname)

def fill_all_accounts(daemon, helper):
    users = daemon.agent.get_all_user()
    good_ids = open('good', 'w')
    bad_ids = open('bad', 'w')
    for user in users:
        try:
            api = daemon.get_api_by_user(user.uname)
            good_ids.write('%s:%s:%s\n'
                           % (user.uname, user.passwd, api.me().name.encode('utf-8')))
            _logger.info('successful fetching api failed for %s' %
                          (user.uname))
        except Exception, err:
            _logger.error('failed fetching api failed for %s: %s' %
                          (user.uname, err))
            bad_ids.write('%s:%s\n' % (user.uname, user.passwd))
            # try:
            #     fill_account(daemon, helper, user)
            # except Exception, err:
            #     _logger.error('fill_account failed for (%s): %s' %
            #                   (user.uname, err))
        time.sleep(1)
    good_ids.close()
    bad_ids.close()

def main(argv):
    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'u:d:p:', ['user=', 'db=', 'passwd='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()
        sys.exit(2)

    dbuser = 'taras'
    db = 'taras'
    passwd = 'admin123'
    for opt, arg in opts:
        if opt in ('-u', '--user'):
            dbuser = arg
        if opt in ('-d', '--db'):
            db = arg
        if opt in ('-p', '--passwd'):
            passwd = arg

    daemon = taras.WeiboDaemon(dbname=db, dbuser = dbuser, dbpass = passwd)
    helper = taras.WeiboDaemon(dbname=db, dbuser = dbuser, dbpass = passwd)
    try:
        fill_all_accounts(daemon, helper)
    except Exception, err:
        _logger.error('fill_all_accounts failed: %s, %s'
                      % (err, traceback.format_exc()))
    except KeyboardInterrupt, sigint:
        _logger.info('got SIGINT, will shutdown gracefully')
    finally:
        daemon.shutdown()
        helper.shutdown()

if __name__ == "__main__":
    main(sys.argv[1:])

