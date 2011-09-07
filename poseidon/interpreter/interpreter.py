import logging
import logging.config
import os
import re
import sys
import traceback
import string
import cPickle

from os.path import abspath, dirname, sep
current_dirname = dirname(abspath(__file__)) + sep
sys.path.append(abspath(current_dirname + '../../'))

from third_party.BeautifulSoup import BeautifulSoup, Comment

# create logger and config
from util.log import _logger
from util.config import get_config
_config = get_config('poseidon')

# Filter out short sentences or phrases, if possible.
# Google like long paragraphs, so do we.
def is_valid_text(text):
    return text.find(',') != -1 and text.find('.') != -1 and len(text) >= 200

def parse_html(doc):
    html = doc['content']
    # Remove comments, <script>, <style>
    try:
        soup = BeautifulSoup(html)
    except Exception, err:
        _logger.error('Failed to create BeautifulSoup for the document with url: ' + doc['url'] + '\n'
                      + traceback.format_exc())
        return []
        
    comments = soup.findAll(text = lambda text: isinstance(text, Comment))
    [comment.extract() for comment in comments]
    c = soup.findAll('script')
    [i.extract() for i in c]
    s = soup.findAll('style')
    [i.extract() for i in s]
    try:
        texts = ''.join(soup.findAll(text=True))
        texts = string.replace(texts, '\r', '\n')
        from HTMLParser import HTMLParser
        texts = HTMLParser().unescape(texts)
    except Exception, err:
        _logger.error('BeautifulSoup created but it failed to process doc, url: ' + doc['url'] + '\n'
                      + traceback.format_exc())
        return []
    else:
        return [re.sub(r'\s+', ' ', text.strip()) for text in texts.split('\n\n')]

def interpret(inpath, outpath):
    with open(inpath, "rb") as crawled_docs:
        docs = cPickle.load(crawled_docs)
    _logger.info('found ' + str(len(docs)) + ' docs from crawler\'s output')

    output_str = u''
    for doc in docs:
        _logger.info('processing doc from url: ' + doc['url'])
        contents = parse_html(doc)
        output_str += unicode(doc['url'] + '\n\n' + '+' * 100 + '\n\n')
        for paragraph in contents:
            if is_valid_text(paragraph):
                output_str += unicode(paragraph + '\n\n' + '+' * 100 + '\n\n')
        output_str += ('\n\n' + '=' * 100 + '\n')
    with open(outpath, "w") as output:
        output.write(output_str.encode('utf-8'))
    
# Unit test
if __name__ == "__main__":
    interpret('crawler_out', 'interpret_out')

