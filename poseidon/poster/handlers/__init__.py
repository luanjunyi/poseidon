#! /usr/bin/python

__author__="johnx"
__date__ ="$Mar 29, 2011 1:58:18 PM$"

from dvbbs_v1 import dvbbs_handler
from wp import wp_handler

__all__ = [
    dvbbs_handler,
    wp_handler,
]

if __name__ == "__main__":
    print "not for execution";
