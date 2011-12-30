import MySQLdb
import hashlib
from taras import sql_agent

class dbAgent(sql_agent.SQLAgent):
    def add_pic(self, filepath, title, description, author, tags, md5, popularity):
        self.cursor.execute("insert into picture(title, description, author, tags, filepath, md5, popularity)\
 values(%s, %s, %s, %s, %s, %s, %s)",
                            (title, description, author, tags, filepath, md5, popularity))
        self.conn.commit()

    def pic_exists(self, md5):
        self.cursor.execute("select count(*) as count from picture where md5 = %s", md5)
        ret = self.cursor.fetchone()['count'] > 0
        self.cursor.fetchall()
        return ret

    def get_all_pic(self):
        self.cursor.execute("select * from picture")
        return self.cursor.fetchall()

    def get_pic_by_filepath(self, path):
        self.cursor.execute("select * from picture where filepath = %s", path)
        ret = self.cursor.fetchone()
        self.cursor.fetchall()
        return ret

    def remove_pic_by_id(self, id):
        self.cursor.execute("delete from picture where id = %s", id)
        self.conn.commit()

    def update_popularity(self, md5, popularity):
        self.cursor.execute("update picture set popularity = %s where md5 = %s", (popularity, md5))
        self.conn.commit()
