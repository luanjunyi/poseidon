# This module a wrapper of MYSQLdb.py
# Caveat:
# auto-commit is disabled by defaut per some API standard. Therefore we must add
# commit explicitly on every 'write' SQL command. Otherwise, as implied by some ducument,
# no change can take effect for innodb engine

import sys, os, cPickle, random, hashlib, re, types, time
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Poseidon root
from datetime import datetime, timedelta, date
from util.log import _logger
from third_party import chardet
import MySQLdb


extend_dict = dict()

def extending_agent(cls):
    dct = extend_dict.setdefault(cls.__name__, dict())
    for k in dir(cls):
        v = getattr(cls, k)
        if callable(v) and not k.startswith("__"):
            dct[k] = v
    return cls

class MetaAgent(type):
    def __init__(cls, name, bases, dct):
        if 'extend_key' in dct:
            global extend_dict
            for key, method in extend_dict.get(dct['extend_key'], dict()).items():
                if callable(method) and (key not in dct) and (not key.startswith('__')):
                    setattr(cls, key, method.im_func)
        super(MetaAgent, cls).__init__(name, bases, dct)                

class SQLAgent(object):
    __metaclass__ = MetaAgent
    # set sscursor to True if want to store the result set in server. It's for large result set
    def __init__(self, db_name, db_user, db_pass, host = "localhost", sscursor = False):
        self.db_name = db_name
        self.db_user = db_user
        self.db_pass = db_pass
        self.db_host = host
        self.use_sscursor = sscursor

    def start(self):
        _logger.info('connecting DB... host:%s %s@%s:%s' % (self.db_host, self.db_user, self.db_name, self.db_pass))
        self.conn = MySQLdb.connect(host = self.db_host,
                                    user = self.db_user,
                                    passwd = self.db_pass,
                                    db = self.db_name,
                                    )
        if self.use_sscursor: # store result in server
            self.cursor = self.conn.cursor(MySQLdb.cursors.SSDictCursor)
        else:
            self.cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)

        self.cursor.old_execute = self.cursor.execute
        self.cursor.execute = self.safe_execute

        self.cursor.execute('set names utf8')
        self.conn.commit()

    def stop(self):
        try:
            self.cursor.close()
            self.conn.close()
        except Exception, err:
            _logger.error('stopping SQLAgent failed: %s, will continue anyway' % err)
        _logger.info('sql agent stopped')

    def restart(self):
        self.stop()
        self.start()

    def safe_execute(self, *argv, **kwargv):
        while True:
            try:
                ret = self.cursor.old_execute(*argv, **kwargv)
                return ret
            except MySQLdb.OperationalError, err:
                if err[0] == 2006:
                    _logger.error('MySQL has gone away, will restart agent')
                    self.restart()
            else:
                return None
                
class ORMTableRow(object):
    def __init__(self, row_dict = {}, table = None):
        object.__setattr__(self, 'dict', row_dict)
        object.__setattr__(self, 'table', table)

    def __getattr__(self, name):
        return self.dict[name]

    def __setattr__(self, name, value):
        self.dict[name] = value

    def save(self):
        self.table.add(self, force=True)

class ORMTable(object):
    def __init__(self, name, pk_columns):
        self.agent = None
        self.name = name
        self.pk_columns = pk_columns
        if len(self.pk_columns) == 0:
            raise Exception('invalid ORMTable pk_columns is empty')

    def _exclude_none(self, iterable):
        if not hasattr(iterable, '__iter__'):
            return iterable
        return filter(lambda a: a != None, iterable)

    def _compose_where_clause_with_keys(self, keys):
        if len(keys) > 0:
            predicates = []
            for key in keys:
                if key.endswith('/n'):
                    cur = "%(key)s is null" % {'key': key[:-2]}
                elif key.endswith('/nn'):
                    cur = "%(key)s is not null" % {'key': key[:-3]}
                else:
                    if key.endswith('>'):
                        op = '>'
                        key = key[:-1]
                    elif key.endswith('<'):
                        op = '<'
                        key = key[:-1]
                    elif key.endswith('!='):
                        op = '!='
                        key = key[:-2]
                    else:
                        op = '='
                    cur = "%(key)s %(op)s %%s" % {'key': key, 'op': op}
                predicates.append(cur)
            return " and ".join(predicates)
        else:
            return ' 1 '

    def _compose_order_by(self, order_by):
        if len(order_by) == 0:
            return ''
        return ' order by ' + ', '.join(["%s %s" % (k, v) for k, v in order_by.items()])


    def exists(self, predicate_dict):
        return self.get_row_num(predicate_dict) > 0

    def get_row_num(self, predicate_dict = {}):
        sql = "select count(*) as count from %s where %s" % (self.name,
                                                             self._compose_where_clause_with_keys(predicate_dict.keys()))
        values = self._exclude_none(predicate_dict.values())
        self.agent.cursor.execute(sql, values)
        return self.agent.cursor.fetchone()['count']


    def find(self, predicate_dict = {}, order_by = {}):
        sql = "select * from %(table)s where %(where)s %(orderby)s limit 1 " % \
            {'table': self.name,
             'where': self._compose_where_clause_with_keys(predicate_dict.keys()),
             'orderby': self._compose_order_by(order_by)}
        values = self._exclude_none(predicate_dict.values())

        self.agent.cursor.execute(sql, values)
        item = self.agent.cursor.fetchone()
        return ORMTableRow(item, self) if item != None else None

    def find_all(self, predicate_dict = dict(), limit = -1, order_by = (), distinct=False):
        if limit > 0:
            sql = "select * from %s where %s limit %d" % (self.name,
                                                    self._compose_where_clause_with_keys(predicate_dict.keys()),
                                                    limit)
        else:
            sql = "select * from %s where %s" % (self.name,
                                                 self._compose_where_clause_with_keys(predicate_dict.keys()))

        values = self._exclude_none(predicate_dict.values())
        self.agent.cursor.execute(sql, values)
        return [ORMTableRow(row, self) for row in self.agent.cursor.fetchall()]

    # Different from find_all, find_many execute many selects statement
    def find_many(self, columns, values):
        sql = "select * from %s where %s " % (self.name, self._compose_where_clause_with_keys(columns))
        result = []
        for value in values:
            value = self._exclude_none(value)
            self.agent.cursor.execute(sql, value)
            result.extend([ORMTableRow(row, self) for row in self.agent.cursor.fetchall()])
        return result

    def add(self, row, force=False, ignore_err = False):
        if type(row) == ORMTableRow:
            row = row.dict

        if force:
            operation = 'replace'
            ignore_err = False
        else:
            operation = 'insert'

        ignore_str = 'ignore' if ignore_err else ''
        sql = "%s %s into %s(%s) values(%s)" % (operation,
                                                ignore_str,
                                                self.name,
                                                ", ".join(row.keys()),
                                                ", ".join(["%s" for v in row.values()]))
        self.agent.cursor.execute(sql, row.values())
        self.agent.conn.commit()

    def add_many(self, columns, values, force=False, ignore_err=False):
        if force:
            operation = 'replace'
            ignore_err = False
        else:
            operation = 'insert'

        ignore_str = '' if ignore_err else 'ignore'

        sql = "%s %s into %s(%s) values(%s)" % (operation,
                                                ignore_str,
                                                self.name,
                                                ", ".join(columns),
                                                ", ".join(["%s" for c in columns]))
        self.agent.cursor.executemany(sql, values)
        self.agent.conn.commit()
                                                        

    def remove(self, predicate_dict):
        if (type(predicate_dict) == ORMTableRow):
            predicate_dict = predicate_dict.dict
        sql = "delete from %s where %s" % (self.name,
                                           self._compose_where_clause_with_keys(predicate_dict.keys()))
        values = self._exclude_none(predicate_dict.values())
        self.agent.cursor.execute(sql, values)
        self.agent.conn.commit()

    def update_row(self, row):
        if type(row) == ORMTableRow:
            row_dict = row.dict
        else:
            row_dict = row

        predicate_dict = dict()
        for key in self.pk_columns:
            predicate_dict[key] = row_dict[key]
        self.update(row_dict, predicate_dict)

    def update(self, row_dict, predicate_dict = dict()):
        sql = "update %s set %s where %s" % (self.name,
                                             ', '.join([("%s = '%s'" % (k,v)) for k, v in row_dict.items()]),
                                             self._compose_where_clause_with_keys(predicate_dict.keys()))

        values = self._exclude_none(predicate_dict.values())
        self.agent.cursor.execute(sql, values)
        self.agent.conn.commit()

def orm_from_connection(dbuser, dbpass, dbname, dbhost = 'localhost', sscursor = False, extending_key = None):
    class ORMAgent(SQLAgent):
        extend_key = extending_key
        def __init__(self):
            super(ORMAgent, self).__init__(dbname, dbuser, dbpass, dbhost, sscursor)
            for table_name in self.table_names:
                getattr(self, table_name).agent = self

    agent = SQLAgent(dbname, dbuser, dbpass, dbhost)
    agent.start()

    ORMAgent.table_names = []
    agent.cursor.execute('show tables')
    for item in agent.cursor.fetchall():
        table_name = item.values()[0]
        agent.cursor.execute('show index from %s where key_name = "primary"' % table_name)
        setattr(ORMAgent, table_name, ORMTable(table_name, pk_columns = [item['Column_name'] for item in agent.cursor.fetchall()]))
        ORMAgent.table_names.append(table_name)
    agent.stop()

    return ORMAgent

def agent_from_connection(*argv, **kwargv):
    AgentClass = orm_from_connection(*argv, **kwargv)
    return AgentClass()

if __name__ == "__main__":
    _logger.info("testing sql_agent")
    ORM = orm_from_connection('junyi', 'admin123', 'taras_qq')
    agent = ORM()
    for table in agent.table_names:
        print getattr(agent, table).name
    agent.start()
    print "local user with id = 8276 exists: %s" % agent.local_user.exists({'id': 8276})
    print "local user with id > 8276: %d" % agent.local_user.get_row_num({'id>': 8276})
    print "local user with freeze_to is null: %d" % agent.local_user.get_row_num({'freeze_to/n': None})
    print "local user with freeze_to is not null: %d" % agent.local_user.get_row_num({'freeze_to/nn': None})
    print "local user with freeze_to total: %d" % agent.local_user.get_row_num()
    u = agent.local_user.find({'identity': '2310663584',
                                 'id': 8276})
    print u
    print dir(u)
    # agent.core_config.remove()
    # agent.core_config.add({'name': 'vender-type',
    #                        'value': 'qq',
    #                        'extra': 'type of current micro-blogging vender'})
    # agent.core_config.add({'name': 'vender-type1',
    #                        'value': 'qq',
    #                        'extra': 'type of current micro-blogging vender'})
    # agent.core_config.add({'name': 'vender-type2',
    #                        'value': 'qq',
    #                        'extra': 'type of current micro-blogging vender'})
    # t = agent.core_config.find({'name': 'vender-type1'})
    # t.value = 'sina'
    # t.save()
    # agent.core_config.update({'value': 'qq-api'}, {'name': 'vender-type2'})
    agent.stop()
