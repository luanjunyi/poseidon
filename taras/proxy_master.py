import os, sys, re, random, traceback, time, math
from datetime import datetime, timedelta

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Paracode root

from sql_agent import Tweet, SQLAgent
from util.log import _logger

PROXY_TRYOUT_COUNT = 100
VALID_PROXY_FAIL_RATE = 0.3

def pick_proxy_for_slot(agent, slot_id, all_proxy):
    proxies = [proxy for proxy in all_proxy if proxy['slot_id'] == None]
    if len(proxies) == 0:
        _logger.error("No free proxy for slot %d" % slot_id)
        return
    for proxy in proxies:
        if not bad_proxy(proxy):
            _logger.debug("got healthy proxy at %s" % proxy['addr'])
            agent.update_proxy_slot(slot_id, proxy)
            proxy['slot_id'] = slot_id
            return
            
    _logger.error("Can't find any decent proxy for slot %d" % slot_id)

def bad_proxy(proxy):
    proxy_log = agent.get_proxy_log(proxy)
    if proxy_log == None or proxy_log['use_count'] < PROXY_TRYOUT_COUNT \
            or float(proxy_log['fail_count']) / float(proxy_log['use_count']) < VALID_PROXY_FAIL_RATE:
        return False
    else:
        _logger.debug("bad proxy: addr=%s, use=%d, fail=%d, fail_rate=%.2f%%" %
                     (proxy['addr'], proxy_log['use_count'], proxy_log['fail_count'],
                      float(proxy_log['fail_count']) / float(proxy_log['use_count']) * 100))
        return True



def check_proxies(agent):
    config = agent.get_core_config()
    PROXY_TRYOUT_COUNT = int(config['proxy_tryout_count'])
    VALID_PROXY_FAIL_RATE = float(config['valid_proxy_fail_rate'])

    all_proxy = agent.get_all_proxy()
    account_num = agent.get_enabled_user_count()
    slot_num = math.ceil(account_num / 50.0)
    slot_num = int(slot_num)
    _logger.info("%d account, %d proxy slots, fail rate limit: %.2f%%, try out: %d" % 
                 (account_num, slot_num, VALID_PROXY_FAIL_RATE * 100, PROXY_TRYOUT_COUNT))

    for slot_id in range(slot_num):
        proxy = agent.get_proxy_by_slot(slot_id)
        if proxy == None:
            _logger.info("proxy slot #%d is empty, try picking proxy for it" % slot_id)
            pick_proxy_for_slot(agent, slot_id, all_proxy)
        elif bad_proxy(proxy):
            _logger.info("proxy slot #%d is bad with addr: %s, will pick new one" % (slot_id, proxy['addr']))
            agent.remove_proxy_from_slot(proxy)
            pick_proxy_for_slot(agent, slot_id, all_proxy)
        else:
            _logger.info("proxy slot #%d OK, addr: %s" % (slot_id, proxy['addr']))

if __name__ == "__main__":
    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 'h:u:p:d:', ['host=', 'user=', 'passwd=', 'database='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()

    dbhost = 'localhost'
    dbname = 'taras'
    dbuser = 'taras'
    dbpass = 'admin123'

    for opt, arg in opts:
        if opt in ('-h', '--host'):
            dbhost = arg
        if opt in ('-u', '--user'):
            dbuser = arg
        if opt in ('-p', '--passwd'):
            dbpass = arg
        if opt in ('-d', '--database'):
            dbname = arg

    agent = SQLAgent(dbname, dbuser, dbpass, dbhost)

    while True:
        check_proxies(agent)
        _logger.info("sleeping for 60 sec")
        time.sleep(10)
