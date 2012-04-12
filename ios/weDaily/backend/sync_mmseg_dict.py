import sys, os
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '../../../'))

from util.log import _logger
from db import WeeSQLAgent
from indexer import Indexer

# deployment config
DB_NAME = 'weDaily'
DB_USER = 'junyi'
DB_PASSWORD = 'admin123'
DICT_FILE_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../../../third_party/mmseg/data/', 'sougou.dic')

def main():
    _logger.info("checking dict from %s" % DICT_FILE_PATH)
    with open(DICT_FILE_PATH, 'a+') as dict_file:
        # load all data
        exists = [term.split(' ')[1] for term in [line for line in dict_file.read().split('\n')] if term != '']
        _logger.info("%d term exists in old dict" % len(exists))

        agent = WeeSQLAgent(DB_NAME, DB_USER, DB_PASSWORD)        
        agent.start()
        terms = agent.get_all_custom_tags()
        
        _logger.info("checking %d custom tags" % len(terms))

        unindexed_terms = []

        for term in terms:
            text = term['tag']
            _logger.debug('checking %s' % text)
            if text not in exists:
                _logger.info("adding %s to dict" % text)
                dict_file.write("%d %s\n" % (len(text.decode('utf-8')), text))
                unindexed_terms.append(text)

        _logger.info("dict updated")

        if len(unindexed_terms) > 0:
            _logger.info("need to update index for %d terms" % len(unindexed_terms))
            indexer = Indexer(agent)
            indexer.update_index_for_terms(unindexed_terms)

        agent.stop()



if __name__ == "__main__":
    main()
