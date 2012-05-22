import os, sys, time, math

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../../"))

from db import WeeSQLAgent
from util.log import _logger
from util import nlp
from BeautifulSoup import BeautifulSoup

# deployment config
DB_NAME = 'weDaily'
DB_USER = 'junyi'
DB_PASSWORD = 'admin123'

# behaviour config
SLEEP_SEC = 60

class Indexer:
    def __init__(self, agent):
        self.agent = agent

    def update_index_for_terms(self, unindexed_terms):
        indexed_wee = self.agent.get_all_indexed_wee()
        _logger.info("updating index for %d terms with %d indexed wees" % (len(unindexed_terms), len(indexed_wee)))
        self.update_index(indexed_wee, unindexed_terms)

    def index_new_wee(self):
        unindexed_wee = self.agent.get_all_unindexed_wee()
        self.update_index(unindexed_wee)
        for wee in unindexed_wee:
            self.agent.mark_wee_as_indexed(wee)

    def update_index(self, all_wee, terms = None):

        total_wee_count = self.agent.get_wee_count()

        use_local_contain_count = (terms != None or self.agent.get_index_count() < 100)
        local_num_wee_contain_term = {}

        if use_local_contain_count:
            _logger.info("will calculate idf from current batch")
            # in this loop, get the number of wee containing each term
            for idx,wee in enumerate(all_wee):
                soup = BeautifulSoup(wee['html'])
                tokens = nlp.Tokenizer(soup.text.strip())
                tf = {}
                for token in tokens:
                    token = token.lower()
                    if (terms and not token in terms):
                        continue
                    if not token in tf:
                        tf[token] = 0
                        if not token in local_num_wee_contain_term:
                            local_num_wee_contain_term[token] = 0
                        local_num_wee_contain_term[token] += 1
                    tf[token] += 1

                if idx % 10 == 0:
                    process = "%.1f %% finished" % (float(idx) / len(all_wee) * 100.0)
                    sys.stderr.write(process)
                    sys.stderr.write(len(process) * '\b')
            _logger.debug("idf part done")

        # in this loop, get the term frequency of each term in each wee
        for idx, wee in enumerate(all_wee):
            soup = BeautifulSoup(wee['html'])
            tokens = nlp.Tokenizer(soup.text.strip())
            tf = {}
            for token in tokens:
                token = token.lower()

                if (terms and not token in terms):
                    continue

                if not token in tf:
                    tf[token] = 0
                tf[token] += 1
            for token in tf:
                if use_local_contain_count:
                    containing = local_num_wee_contain_term[token]
                else:
                    containing = 1 + self.agent.get_num_wee_contain_term(token)

                term_in_title = (wee['title'].lower().find(token) != -1)

                weight = math.log(total_wee_count / containing) * tf[token] * (2.0 if term_in_title else 1.0)

                #_logger.debug("term: %s, weight: %.2f containing=%d, tf=%d, in-title:%d, wee-id:%d" % (token, weight, containing, tf[token], term_in_title, wee['id']))
                if (weight > 1.0):
                    try:
                        self.agent.add_inverted_index(token, wee['id'], weight)
                    except Exception, err:
                        _logger.error("add inverted_index failed(%s-%d): %s" % (token, wee['id'], err))

            if idx % 10 == 0:
                process = "%.1f %% finished" % (float(idx) / len(all_wee) * 100.0)
                sys.stderr.write(process)
                sys.stderr.write(len(process) * '\b')



def main():
    _logger.info("wee indexer started")
    agent = WeeSQLAgent(DB_NAME, DB_USER, DB_PASSWORD)
    agent.start()
    _logger.info("MySQL agent started")
    indexer = Indexer(agent)
    while True:
        #agent.restart()
        indexer.index_new_wee()
        _logger.debug("Sleep for %d sec" % SLEEP_SEC)
        time.sleep(SLEEP_SEC)

if __name__ == "__main__":
    main()
