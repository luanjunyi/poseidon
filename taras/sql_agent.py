# This module is all about dealing with MYSQL DB for Taras or related modules
# Caveat:
# auto-commit is disabled by defaut per some API standard. Therefore we must add
# commit explicitly on every 'write' SQL command. Otherwise, as implied by some ducument,
# no change can take effect for innodb engine

import sys, os, cPickle, random, hashlib, re
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), './../')) # Paracode root
import common.sql_agent

from datetime import datetime, timedelta, date
from util.log import _logger
from third_party import chardet
import MySQLdb


DB_NAME='taras_sina'
DB_USER='taras'
DB_PASSWORD='admin123'
DB_HOST='localhost'
TarasSQLAgent = None



@common.sql_agent.extending_agent
class TarasSQLAgent(common.sql_agent.SQLAgent):
    def _split_by_sharp(self, value):
        if value == None:
            return []

        items = filter(lambda i: len(i) > 0, value.split('#'))
        return map(lambda i: i.strip(), items)

    def get_all_user(self):
        """
        Get all enabled, non-frozen users from DB
        Side-effect: release frozen user if freeze_to date is passed
        """
        users = self.local_user.find_all({'enabled': 1})
        for user in users:
            object.__setattr__(user, 'tags', self._split_by_sharp(user.tags))
            object.__setattr__(user, 'poison_tags', self._split_by_sharp(user.poison_tags))
            object.__setattr__(user, 'victim_keywords', self._split_by_sharp(user.victim_keywords))
            object.__setattr__(user, 'sources', self._split_by_sharp(user.sources))
            object.__setattr__(user, 'categories', self._split_by_sharp(user.categories))

        random.shuffle(users)
        return users

    def add_victims(self, user_id, victims):
        if len(victims) == 0:
            return 0

        value_str = ''
        for index, victim in enumerate(victims):
            if index == 0:
                value_str += '(%d, "%s")' % (user_id, victim)
            else:
                value_str += ', (%d, "%s")' % (user_id, victim)
        sql = 'insert ignore victim_crawled(user_id, victim) values %s' %  value_str
        self.cursor.execute(sql)
        self.conn.commit()
        return self.cursor.rowcount

    def update_proxy_log(self, proxy_addr, log_type):
        cur_date = datetime.now().strftime("%Y-%m-%d")

        self.cursor.execute("select * from proxy_log where proxy_ip = %s and collect_date = %s", (proxy_addr, cur_date))

        row = self.proxy_log.find({'proxy_ip': proxy_addr,
                                   'collect_date': cur_date})
        if not row:
            use = 0
            fail = 0
        else:
            use = row.use_count
            fail = row.fail_count

        if log_type == "use":
            use += 1
        elif log_type == "fail":
            fail += 1
            use += 1
        else:
            _logger.error("unknown proxy log type: %s" % log_type)
            return

        self.proxy_log.add({'proxy_ip': proxy_addr,
                            'collect_date': cur_date,
                            'use_count': use,
                            'fail_count': fail},
                           force=True)

    def get_user_statistic(self, user_id):
        stat = self.user_statistic.find({'user_id': user_id,
                                         'collect_date': datetime.now().date().strftime("%Y-%m-%d")})
        if stat == None:
            return common.sql_agent.ORMTableRow({'new_follow': 0, 'new_unfollow': 0, 'new_post': 0},
                                                self.user_statistic)
        else:
            return stat

def init(dbname, dbuser, dbpass, dbhost='localhost', sscursor=False):
    global TarasSQLAgent
    TarasSQLAgent = common.sql_agent.orm_from_connection(dbuser, dbpass, dbname, dbhost, sscursor, 'TarasSQLAgent')
    agent = TarasSQLAgent()
    return agent



