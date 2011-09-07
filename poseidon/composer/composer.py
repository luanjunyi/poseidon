import logging
import logging.config
import os
import re
import sys
import traceback
import string
import random
import pickle

from os.path import abspath, dirname, sep
current_dirname = dirname(abspath(__file__)) + sep
sys.path.append(abspath(current_dirname + '../../'))
sys.path.append(abspath(current_dirname + '../../third_party'))
sys.path.append(abspath(current_dirname + '../../util'))

doc_sep = '=' * 100
paragraph_sep = '+' * 100

# create logger
from util.log import _logger

_exchange = dict()

def _build_exchange():
    global _exchange
    dict_file = open(os.path.dirname(os.path.abspath(__file__)) + os.path.sep + 'dict')
    dict_file_all = dict_file.read()
    dict_file.close()
    dict_list = dict_file_all.split('\n')
    for item in dict_list:
        words = [word.strip() for word in item.split(',')]
        for i in range(len(words)):
            _exchange[words[i]] = [words[(i + 1) % len(words)], words[(i + 2) % len(words)]]

def get_synonym(word):
    if word in _exchange:
        return _exchange[word][random.randint(0, len(_exchange[word]) - 1)]
    else:
        return word

def _parse_paragraphs(infile):
    docs = infile.read()
    docs = [doc.strip() for doc in docs.split(doc_sep)]
    paragraphs = []
    for doc in docs:
        para = [para.strip() for para in doc.split(paragraph_sep) if len(para.strip()) >= 100 or para.find('http://') == 0]
        paragraphs.extend(para[1:])
    return paragraphs

def synonyms_exchange(paragraph):
    # disable this feature for now
    return paragraph
    words = paragraph.split(' ')
    changed = 0
    for word in words:
        subword = get_synonym(word)
        if subword != word:
            try:
                paragraph = paragraph.replace(word, subword)
            except:
                print '(' + word + ') -> (' + subword + ')\n'
                traceback.print_exc()
                sys.exit()
            changed += 1
        if 10 * changed >= len(words):
            break
    return paragraph

def rewrite(paragraph):
    random.seed()
    #paragraph = synonyms_exchange(paragraph)
    if random.randint(0, 3) > 0:
        return paragraph
    sentences = paragraph.split('.')
    sentences = [sentence.strip() for sentence in sentences]
    random.shuffle(sentences)
    return '. '.join(sentences)

def write_one_article(paragraphs, least = 200, most = 500):
    random.seed()

    article = ''
    # set the article length
    len_needed = random.randint(least, most)
    
    current_len = 0
    while current_len < len_needed:
    # pick up one paragraph
        index = random.randint(0, len(paragraphs) - 1)
        paragraph = rewrite(paragraphs[index])
        try:
            current_len += len(paragraph.split(' '))
        except Exception:
            print 'index: ' + str(index) + '\nparagraph:---->' + paragraphs[index] + '\n\n---------------\n\n'
            traceback.print_exc()
        article += paragraph + '\n\n'

    return article.strip()

class _LinkDropper:
    class _Dropper:
        def __init__(self, links):
            self.links = links
            self.index = 0

        def __call__(self, match_obj):
            anchor = match_obj.group(0)
            repl = '<a href=%(url)s>%(anchor)s</a>' % {'url': self.links[self.index], 'anchor': anchor}
            _logger.debug('replacing %s with %s' % (anchor, repl))
            self.index = (self.index + 1) % len(self.links)
            return repl

    def __init__(self, link_info):
        self.link_info = link_info

    def _drop_links(self, article):
        # drop 3~8 links
        words = map(str.strip, re.findall('.+? ', article))
        link_num = random.randint(3, 8)
        for i in range(link_num):
            anchor = random.choice(self.link_info.keys())
            href = random.choice(self.link_info[anchor])
            article = article.replace(random.choice(words), '<a href="%s">%s</a>,' % (href, anchor), 1)
        return article


def compose(infile, outfile, count, link_info, min_word = 200, max_word = 500):
    infile = open(infile)
    paragraphs = _parse_paragraphs(infile)
    infile.close()
    articles = []
    link_dropper = _LinkDropper(link_info)
    for i in range(0, count):
        _logger.info('writing article ' + str(i) + ' of ' + str(count))
        articles.append(link_dropper._drop_links(write_one_article(paragraphs, min_word, max_word)) + '\n\n')
    outfile = open(outfile, 'w')
    outfile.write(('\n\n' + doc_sep + '\n\n').join(articles))
    outfile.close()

def parse_composed(infile):
    with open(infile) as infile:
        docs = infile.read()
        return map(lambda item: item.strip(), docs.split(doc_sep))

_build_exchange()

if __name__ == '__main__':
    count = 100
    if len(sys.argv) == 2:
        count = int(sys.argv[1])
    _logger.info('testing composer by calling compose(%d, \'composer_out\')', count)

    link_info = {}
    with open('links') as links:
        link_data = links.read()
        link_data = filter(lambda text: len(text) > 0, link_data.split('\n'))
        if len(link_data) < 2:
            _logger.critical('enconter syntax error in link_file:' + 'links' + ', problematic line(s): ' + '\n'.join(link_data))
        link_info[link_data[0]] = link_data[1:]
    compose('interpret_out', 'composer_out', link_info, count)
    
