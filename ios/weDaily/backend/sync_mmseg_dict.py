# coding=utf-8

import sys, os, time
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '../../../'))

from util.log import _logger
from db import WeeSQLAgent


# deployment config
DB_NAME = 'weDaily'
DB_USER = 'junyi'
DB_PASSWORD = 'admin123'
DICT_FILE_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../../../third_party/mmseg/data/', 'sougou.dic')
SLEEP_SECOND = 60 * 15

def main():
    _logger.info("checking dict from %s" % DICT_FILE_PATH)
    agent = WeeSQLAgent(DB_NAME, DB_USER, DB_PASSWORD)        
    agent.start()
    unindexed_terms = []

    dict_file = open(DICT_FILE_PATH, 'a+')

    # load all data
    exists = [term.split(' ')[1] for term in [line for line in dict_file.read().split('\n')] if term != '']
    _logger.info("%d term exists in old dict" % len(exists))

    terms = agent.get_all_custom_tags()

    _logger.info("checking %d custom tags" % len(terms))

    for term in terms:
        text = term['tag']
        _logger.debug('checking %s' % text)
        if text.find(' ') == -1 and text not in exists: # ignore if text contains space
            _logger.info("adding %s to dict" % text)
            dict_file.write("%d %s\n" % (len(text.decode('utf-8')), text))
            unindexed_terms.append(text)

    dict_file.flush()
    os.fsync(dict_file.fileno())
    dict_file.close()
    _logger.info("dict updated")

    if len(unindexed_terms) > 0:
        _logger.info("unindexed terms:(%s)" % ",".join(unindexed_terms))
        # must import here rather than in the beginning of file
        # because dict file will be read only when Indexer is imported and
        # we've just updated the dict
        # from indexer import Indexer 
        # _logger.info("need to update index for %d terms" % len(unindexed_terms))
        # time.sleep(5)
        # indexer = Indexer(agent)
        # indexer.update_index_for_terms(unindexed_terms)
    else:
        _logger.info("no new tags found")

    agent.stop()



if __name__ == "__main__":
    while True:
        main()
        _logger.debug("sleep for %d seconds" % SLEEP_SECOND)
        time.sleep(SLEEP_SECOND)

