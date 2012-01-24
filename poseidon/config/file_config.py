#! /usr/bin/python

__author__="johnx"
__date__ ="$Mar 14, 2011 6:30:39 PM$"

#instance of RawConfigParser holding the handle of whole application config
_config = None
def load_config():
    global _config
    import ConfigParser
    _config = ConfigParser.RawConfigParser()
    _config.read('poseidon.conf')

class PoseidonConfig:

    _section = None
    _config = None

    def __init__(self, section, config = _config):
        self._section = section
        self._config = config
    def __getitem__(self, key):
        return self._config.get(self._section, key)

def get_config(section):
    return PoseidonConfig(section, _config)

if __name__ == "__main__":
    print "not for execution";
else:
    load_config()
