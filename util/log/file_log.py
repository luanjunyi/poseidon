#! /usr/bin/python

__author__="Administrator"
__date__ ="$Mar 14, 2011 6:22:49 PM$"
__version__ = '0.1.0'

_logger = None

import logging, logging.config, sys, traceback

def handleError(self, record):
    sys.stderr.write('===The Python Logging Failed===')
    traceback.print_stack()

def _build_logger():
    logging.Handler.handleError = handleError
    global _logger
    if _logger == None:
        # create logger
        try:
            logging.config.fileConfig("logger.conf")
            _logger = logging.getLogger("root")
        except Exception, err:
            # create a simple logger
            import sys
            sys.stderr.write("failed to load logger.conf, will log to stderr: %s\n" % err)
            logging.basicConfig(format="%(asctime)s - %(levelname)s - %(module)s(%(lineno)d): %(message)s",
                                level = logging.DEBUG, stream = sys.stderr)
            _logger = logging.getLogger('root')

    return _logger

if __name__ == "__main__":
    print "not for execution";
else:
    _build_logger()
