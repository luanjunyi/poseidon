
import os, sys, traceback
from datetime import datetime
import httplib2, socks, socket

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), './../')) # Poseidon base path

from util.log import _logger


def proxy_wrapped(func, proxy_info, agent):
    def function_wrapped(*argv, **kwargv):
        try:
            ret = func(*argv, **kwargv)
            agent.update_proxy_log(proxy_info.proxy_host, 'use')
            return ret
        except socks.ProxyError, err:
            agent.update_proxy_log(proxy_info.proxy_host, 'fail')
            raise Exception("Got socks.ProxyError: %s, IP:(%s), port:(%d), user:(%s), passwd:(%s)" %
                            (err,
                             proxy_info.proxy_host, proxy_info.proxy_port,
                             proxy_info.proxy_user, proxy_info.proxy_pass))
        except socket.error, err:
            agent.update_proxy_log(proxy_info.proxy_host, 'fail')
            raise Exception("Got socket.error: %s, IP:(%s), port:(%d), user:(%s), passwd:(%s)" %
                            (err,
                             proxy_info.proxy_host, proxy_info.proxy_port,
                             proxy_info.proxy_user, proxy_info.proxy_pass))
        except Exception, err:
            if str(err) == "time out":
                agent.update_proxy_log(proxy_info.proxy_host, 'fail')
                raise Exception("Proxied Connection out, proxy IP:(%s), port:(%d), user:(%s), passwd:(%s)" %
                                (err,
                                 proxy_info.proxy_host, proxy_info.proxy_port,
                                 proxy_info.proxy_user, proxy_info.proxy_pass))
            else:
                raise Exception(traceback.format_exc())
    return function_wrapped


class ProxyManager:
    def __init__(self, agent):
        self.agent = agent
        self.USER_COUNT_PER_IP = self.agent.core_config.find({'name': 'user_count_per_proxy'}).value
        self.PROXY_TRYOUT_COUNT = self.agent.core_config.find({'name': 'proxy_tryout_count'}).value
        self.VALID_PROXY_FAIL_RATE = self.agent.core_config.find({'name': 'valid_proxy_fail_rate_limit'}).value
        self.DEFAULT_HTTP_TIMEOUT_IN_SEC = self.agent.core_config.find({'name': 'default_proxy_timeout_in_second'}).value


    def _is_proxy_bad(self, proxy):
        proxy_log = self.agent.proxy_log.find({'proxy_ip': proxy.addr,
                                               'collect_date': datetime.now().strftime('%Y-%m-%d')})

        if proxy_log == None \
                or proxy_log.use_count < self.PROXY_TRYOUT_COUNT\
                or float(proxy_log.fail_count) / float(proxy_log.use_count) < self.VALID_PROXY_FAIL_RATE:
            return False
        else:
            _logger.debug("bad proxy: addr=%s, use=%d, fail=%d, fail_rate=%.2f%%" %
                          (proxy.addr, proxy_log.use_count, proxy_log.fail_count,
                           float(proxy_log.fail_count) / float(proxy_log.use_count) * 100))
            return True

    def get_proxy_slot_for_user(self, user_id):
        user_id_rank = self.agent.local_user.get_row_num({'id<': user_id})
        slot_id = user_id_rank / self.USER_COUNT_PER_IP
        return slot_id

    def fill_slot(self, slot_id):
        proxies = self.agent.proxy.find_all({'slot_id/n': None})
        if len(proxies) == 0:
            _logger.error("No free proxy available for slot %d" % slot_id)
            return None

        for proxy in proxies:
            if not self._is_proxy_bad(proxy):
                _logger.debug("got healthy proxy at %s, will fill slot(%d)" % (proxy.addr, slot_id))
                proxy.slot_id = slot_id
                proxy.save()
            return proxy

    def get_proxy_in_slot(self, slot_id):
        proxy = self.agent.proxy.find({'slot_id': slot_id})
        if proxy != None:
            return proxy

        _logger.debug("proxy slot(%d) is empty will try fill it" % slot_id)
        proxy = self.fill_slot(slot_id)
        if proxy == None:
            _logger.error('Failed to fill proxy for slot(%d)' % slot_id)
        return proxy

    def get_proxy_for_user(self, user_id):
        slot_id = self.get_proxy_slot_for_user(user_id)
        proxy = self.get_proxy_in_slot(slot_id)
        return proxy

    def get_proxied_connection_for_user(self, user_id):
        proxy = self.get_proxy_for_user(user_id)
        _logger.debug("will use %s for user(%d)" % (proxy.addr, user_id))
        proxy_info = httplib2.ProxyInfo(socks.PROXY_TYPE_SOCKS5,
                                        proxy.addr, proxy.port,
                                        proxy_user = proxy.user_name,
                                        proxy_pass = proxy.password)
        conn = httplib2.Http(proxy_info = proxy_info, timeout = self.DEFAULT_HTTP_TIMEOUT_IN_SEC)
        conn.request = proxy_wrapped(conn.request, proxy_info, self.agent)
        return conn
        

if __name__ == '__main__':
    from common.sql_agent import orm_from_connection
    import sql_agent
    agent = sql_agent.init('taras_qq', 'junyi', 'admin123')
    agent.start()
    pm = ProxyManager(agent)

    for user in agent.local_user.find_all():
        proxy = pm.get_proxy_for_user(user.id)
        _logger.debug("got proxy(%s) for user(%d)" % (proxy.addr, user.id))
        conn = pm.get_proxied_connection_for_user(user.id)

        resp, content = conn.request('http://var.grampro.com/tool/echo.php')
        #print content
        import re
        m = re.search('\["REMOTE_ADDR"\]=>.*?string\(.+?\).*?"(.+?)"', content, re.S | re.I)
        _logger.debug("echo seen IP as: (%s)" % m.group(1))

    agent.stop()
    
