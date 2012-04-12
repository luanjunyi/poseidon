# This module a wrapper of MYSQLdb.py
# Caveat:
# auto-commit is disabled by defaut per some API standard. Therefore we must add
# commit explicitly on every 'write' SQL command. Otherwise, as implied by some ducument,
# no change can take effect for innodb engine

import sys, os, cPickle, random, hashlib, re
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../') # Poseidon root
from datetime import datetime, timedelta, date
from util.log import _logger
from third_party import chardet
import MySQLdb

class SQLAgent:
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

        self.cursor.execute('set names utf8')
        self.conn.commit()

    def stop(self):
        self.cursor.close()
        self.conn.close()

    def restart(self):
        self.stop()
        self.start()
        

