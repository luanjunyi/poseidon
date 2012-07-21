# Copyright-2012 Junyi Luan
# See LICENSE for details.

"""
weibo API library
"""
__version__ = '1.0'
__author__ = 'Junyi Luan'
__license__ = 'MIT'

from models import Status, User, DirectMessage, Friendship, SavedSearch, SearchResult, ModelFactory, IDSModel
from error import WeibopError
from api import API
from cache import Cache, MemoryCache, FileCache
from auth import BasicAuthHandler, OAuthHandler
from streaming import Stream, StreamListener
from cursor import Cursor

# Global, unauthenticated instance of API
api = API()

def debug(enable=True, level=1):
    import httplib
    httplib.HTTPConnection.debuglevel = level

