import os, sys, time, traceback
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + './../') # Poseidon root

from sql_agent import SQLAgent
from taras import Taras
import api_adapter
from util.log import _logger


def crawl_victim(dbuser, dbpass, dbname, dbhost, api_type):
    agent = SQLAgent(dbname, dbuser, dbpass, dbhost)
    agent.start()
    taras = Taras(api_type, agent)
    while True:
        try:
            all_user = agent.get_all_user()
            for user in all_user:
                taras.assign_user(user) 
                taras.crawl_victim()
            time.sleep(5)
        except Exception, err:
            _logger.error('crawl victim loop failed once:%s', traceback.format_exc())
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


    if command == 'crawl_victim':
        crawl_victim(dbuser, dbpass, dbname, dbhost, api_type)
    else:
        _logger.error('unknown command: (%s)' % command)
        usage()
