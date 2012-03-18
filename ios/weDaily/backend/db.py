import sys, os
from datetime import datetime
import time

sys.path.append("/home/luanjunyi/posiden")

from common.sql_agent import SQLAgent
from util.log import _logger

class WeeSQLAgent(SQLAgent):
    def get_all_sources(self):
        self.cursor.execute("select * from wee_source")
        return self.cursor.fetchall()

    def get_source_id(self, url):
        self.cursor.execute("select id from wee_source where url = %s", url);
        if self.cursor.rowcount > 0:
            return self.cursor.fetchone()['id']
        else:
            return -1

    def add_wee_source(self, url, pr = 0, tags = []):
        source_id = self.get_source_id(url)
        if source_id == -1:
            _logger.debug("source(%s) doesn't exist, will insert" % url)
            self.cursor.execute("insert into wee_source(url, pr) values(%s, %s)", (url, pr))
            self.conn.commit()
            source_id = self.get_source_id(url)
        
        _logger.debug("source(%s) id fetched: %d" % (url, source_id))

        for tag in tags:
            tag = tag.encode('utf-8')
            self.cursor.execute("insert ignore into source_tag values(%s, %s)", (source_id, tag))
            self.conn.commit()
            _logger.debug('tag %s added to source %d' % (tag, source_id))

    def update_source_time(self, source, last_feed_time = None):
        last_crawl_time = int(time.time())
        if last_feed_time:
            self.cursor.execute("update wee_source set last_crawl_time = %s, last_feed_time = %s where id = %s",
                                (last_crawl_time, last_feed_time, source['id']))
        else:
            self.cursor.execute("update wee_source set last_crawl_time = %s where id = %s",
                                (last_crawl_time, source['id']))
        self.conn.commit()

    def wee_exists(self, url):
        self.cursor.execute("select id from wee where url = %s", url)
        return self.cursor.rowcount > 0

    def add_wee(self, source_id, url, title, text, html, updated_time, author = '', tags = []):
        self.cursor.execute('insert into wee(source_id, url, title, text, updated_time, author, html) \
values(%s, %s, %s, %s, %s, %s, %s)', (source_id, url, title, text, updated_time, author, html))

        for tag in tags:
            try:
                self.cursor.execute('insert into wee_tag values(%s, %s)'
                                    , (url, tag))
            except Exception, err:
                _logger.debug("DB failed adding wee tag: %s" % err)
        self.conn.commit()
    def add_wee_image(self, url, image):
        self.cursor.execute("update wee set image_bin = %s where url = %s",
                            (image, url))
        self.conn.commit()
