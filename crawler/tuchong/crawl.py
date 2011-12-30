# -*- coding: utf-8 -*-

import sys, os, cPickle, random, hashlib, re, time, functools, traceback, itertools, math
from datetime import datetime

from util import pbrowser
from util.log import _logger
from BeautifulSoup import BeautifulSoup
from db import dbAgent

TIMEOUT = 30 # 30 seconds

class TuchongCrawler:
    def __init__(self, shard_id = 0, shard_count = 1):
        self.shard_id = shard_id
        self.shard_count = shard_count
        self.author_to_crawl = []
        self.br = pbrowser.get_browser()
        self.logfile = open("log", "a")
        self.crawl_history = self.build_crawl_history()

    def get_all_author(self):
        cur_url = "http://tuchong.com/contacts/rank/"

        while True:
            _logger.debug("opening initial ranking page at %s" % cur_url)
            rank_page = self.br.open(cur_url, timeout=TIMEOUT).read()
            soup = BeautifulSoup(rank_page)

            cur_list = soup.findAll("a", {"data-site-id": True})
            for author in cur_list:
                self.author_to_crawl.append(author['href'])
                _logger.debug('got author %s' % author['href'])
            
            next_page_anchor = soup.findAll('a', 'next')
            if (len(next_page_anchor) > 1):
                _logger.fatal('multiple next page anchor found, url:(%s), next page number:%d'
                              % (cur_url, len(next_page_anchor)))

            if (len(next_page_anchor) == 0):
                break

            cur_url = next_page_anchor[0]['href']

        return self.author_to_crawl

    def grab_image_info_group(self, soup):
        all_info = []
        all_img = soup.findAll('figure', 'post-photo')
        _logger.debug('%d images in group' % len(all_img))
        for img in all_img:
            url = img.find('a')['href']
            all_info.append(self.grab_image_info(url)[0])
            _logger.debug('sleeping for 5 sec')
            time.sleep(5)
        return all_info

    def grab_image_info(self, img_url):
        info = {
            "title": "",
            "description": "",
            "binary": "",
            "author": "",
            "tags": "",
            "ext": "",
            "popularity": ""
            }

        _logger.debug("opening image URL: %s" % img_url)
        try:
            self.br.open(img_url, timeout=TIMEOUT)
        except Exception, err:
            _logger.error('failed to open url: %s' % img_url)
            return info

        soup = BeautifulSoup(self.br.response().read())
        
        if soup.find('h1', 'title') == None:
            # This is a grouped page
            _logger.debug('group image url detected: %s' % img_url)
            return self.grab_image_info_group(soup)

        info['title'] = soup.find('h1', 'title').text.encode('utf-8')
        info['description'] = soup.find('p', 'desc').text.encode('utf-8')

        img = soup.find('img', {'data-post-id': True})
        info['binary'] = self.br.download_image(img['src'], timeout=TIMEOUT).read()

        info['ext'] = os.path.splitext(img['src'])[1].strip('.')
        info['author'] = soup.find('a', 'user-anchor').text.encode('utf-8')
        info['popularity'] = int(soup.find('a', 'favorited').find('em').text)

        tag_list = soup.find('div', 'tag-list')
        if tag_list != None:
            tags = ''
            for tag in tag_list.findAll('a', 'tag'):
                if (len(tag) > 0):
                    tags += '#%s' % tag.text.encode('utf-8')
            tags = tags.strip('#')
            info['tags'] = tags
        
        return [info, ]


    def crawl_one_author(self, url, callback):
        page = 1
        while True:
            _logger.info("openning page URL: %s" % url)
            self.br.open(url, timeout=TIMEOUT)
            soup = BeautifulSoup(self.br.response().read())
            url = self.br.geturl()
            
            img_div = soup.findAll('div', 'images')
            imgs = list(itertools.chain(*[div.findAll('a', target='_blank') for div in img_div]))
            imgs.extend(soup.findAll('a', {'data-location': 'content'}))
            _logger.debug("%d images on this page" % len(imgs))

            for a in imgs:
                img_url = a['href']

                if img_url in self.crawl_history:
                    _logger.debug('ignoring crawled URL: %s' % img_url)
                    continue

                info = None
                try:
                    all_info = self.grab_image_info(img_url)
                    self.logfile.write(img_url + '\n')
                    self.logfile.flush()
                    _logger.debug('image processed %s' % img_url)
                except Exception, err:
                    _logger.error('processing one image url failed, url:%s, %s' % (img_url, err))
                else:
                    for info in all_info:
                        try:
                            if callback != None:
                                callback(info=info)
                        except Exception, err:
                            _logger.error('callback failed, image url: %s, %s, %s' % (img_url, err, traceback.format_exc()))

                _logger.debug('sleeping for 5 sec')
                time.sleep(5)

            _logger.info("returning to page URL: %s" % url)
            self.br.open(url, timeout=TIMEOUT)
            soup = BeautifulSoup(self.br.response().read())

            next_page_anchor = soup.findAll('a', 'next')
            if (len(next_page_anchor) > 1):
                _logger.fatal('multiple next page anchor found, url:(%s), next page number:%d'
                              % (self.br.geturl(), len(next_page_anchor)))
            if (len(next_page_anchor) == 0):
                break
            url = next_page_anchor[0]['href']
            _logger.info('page %d finished' % page)
            page += 1

        _logger.debug("finished crawling author, last url: %s" % self.br.geturl())

    def build_crawl_history(self):
        crawl_log = open('log', 'r')
        log = crawl_log.read().split('\n')
        crawl_log.close()
        return set(log)

    def crawl_authors(self, authors, callback):
        for author in authors:
            cur_url = author
            _logger.info("crawling author from %s" % cur_url)
            try:
                self.crawl_one_author(cur_url, callback)
                _logger.debug('sleeping for 5 sec')
                time.sleep(5)
            except Exception, err:
                _logger.error("crawl one author failed, url:(%s), error:%s, %s" % (cur_url, err, traceback.format_exc()))
                continue


    def crawl(self, callback = None,
              author_file = None):
        _logger.debug("browser init finished")

        self.author_to_crawl = []

        if author_file == None:
            authors = self.get_all_author()
            # Dump authors to local file
            with open("author_list", 'w') as output:
                output.write("\n".join(authors))
        else:
            with open(author_file, 'r') as author_file_input:
                authors = author_file_input.read().split()
                for author in authors:
                    author = author.strip()
                    if len(author) > 0:
                        self.author_to_crawl.append(author)

        amount = int(math.ceil(len(self.author_to_crawl) / float(self.shard_count)))
        start = self.shard_id * amount
        self.author_to_crawl = self.author_to_crawl[start : start + amount]
        _logger.info("crawling %d to %d" % (start, start + amount))
        self.crawl_authors(self.author_to_crawl, callback)

################################################################################

image_path = "/home/luanjunyi/run/tuchong/"
shard_id = 0
shard_count = 1

def get_file_path_by_date(cur_date):
    dirpath =  image_path + cur_date.strftime("%Y-%m-%d")
    return dirpath, "%s/%d-%d" % (dirpath, int(time.time()), shard_id)

def add_to_db(agent, info):
    if info['binary'] == '':
        _logger.error('info binary is empty string, ignore: %s' % info)
        return
    bin = info['binary']
    md5 = hashlib.md5(bin).hexdigest()

    if agent.pic_exists(md5):
        _logger.debug("pic exists in DB, only set popularity")
        agent.update_popularity(md5, info['popularity'])
        return

    dirpath, filepath = get_file_path_by_date(datetime.now())

    if not os.path.exists(dirpath):
        os.mkdir(dirpath)

    filepath = filepath + "." + info['ext']

    with open(filepath,"w") as output:
        output.write(bin)
        
    agent.add_pic(filepath, info['title'], info['description'], info['author'], info['tags'], md5, info['popularity'])

if __name__ == "__main__":
    from getopt import getopt
    try:
        opts, args = getopt(sys.argv[1:], 's:a:p:', ['shard=', 'all-shard=', 'pic-path='])
    except Exception, err:
        print "getopt error:%s" % err
        usage()

    for opt, arg in opts:
        if opt in ('-s', '--shard'):
            shard_id = int(arg)
        if opt in ('-a', '--all-shard'):
            shard_count = int(arg)
        if opt in ('-p', '--pic-path'):
            image_path = arg

    agent = dbAgent(db_name="picful", db_user="taras", db_pass="admin123")
    tuchong = TuchongCrawler(shard_id, shard_count)
    _logger.info("Tuchong crawler started")
    tuchong.crawl(callback = functools.partial(add_to_db, agent=agent), author_file = "/home/luanjunyi/run/tuchong/author_list")
    _logger.info("Tuchong crawler finished")
