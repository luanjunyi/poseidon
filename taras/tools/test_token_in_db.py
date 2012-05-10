#! /usr/bin/python
DB_NAME = 'taras_qq'
DB_USER = 'junyi'
DB_PASS = 'admin123'
DB_HOST = 'localhost'

import os, sys, cPickle, traceback
sys.path.append('/home/luanjunyi/poseidon/')
sys.path.append('/home/luanjunyi/poseidon/taras/sdk/')
import taras.api_adapter
import taras.sql_agent
import taras.sdk.qqweibo.oauth as oauth




agent = taras.sql_agent.init(DB_NAME, DB_USER, DB_PASS, DB_HOST)
agent.start()

APIClass = taras.api_adapter.create_adapted_api("qq")


tokens = agent.app_auth_token.find_all()

print "%d tokens found" % len(tokens)

for rec in tokens:
    app_id = rec.app_id
    app = agent.local_app.find({'id': app_id})
    api = APIClass(app.token, app.secret)
    token = cPickle.loads(rec.value)

    print token.__module__
    continue

    try:
        api.create_api_from_token(token)
        print api.me().name + " is OK"
    except Exception, err:
        print "%d %d failed: %s" % (rec.user_id, rec.app_id, traceback.format_exc())

agent.stop()

print "Testing finished"


