# -*- coding: utf-8 -*-

import time
from tsohu import *
from functools import partial

def test(func, name=None):
    if name == None:
        name = func.__name__
    
    sep = "=" * 100

    print "%s\nTesting '%s'\n%s" % (sep, name, sep)
    ret = func()
    print len(ret)
    item = ret[0]
    for k in dir(item):
        print "(%s): (%s)" % (k, str(getattr(item, k)))
    print ret
    print "%s\n" % sep
    time.sleep(1)

from tsohu import *
auth = OAuthHandler('1JycbwU8LYoBTxZjP0Mk', 'CsjV-vQchAC4(KBU-)9$euEzK5YpA#%u4-=MOn6f')
auth.setToken('773f7f08144da4c63f1bf9b1127fe4ff', 'ca4f6c06f80438b7e2166627e54c579e')
api = API(auth)
print len(api.user_timeline(nick_name=u'宅腐集中营'))
print len(api.user_timeline())

#url = auth.get_authorization_url()
# print "auth url: %s" % url

# vcode = raw_input("verification code:")

# print 'using vcode(%s)' % vcode
# token = auth.get_access_token(vcode)
# print token.key, token.secret
# auth.setToken(token.key, token.secret)


# test(api.public_timeline, 'public timeline')
# test(partial(api.friends_timeline, count=40), 'friends timeline')

#test(api.get_user, 'get user')
