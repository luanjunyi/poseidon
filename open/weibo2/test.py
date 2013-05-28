import api, auth
import sys

api_list = {'public_timeline': 0,
            'home_timeline': 0,
            'friends_timeline': 1}

def test_home_timeline(client):
    ret = client.home_timeline(count = 10, trim_user = 1)
    print "%d tweets found:" % len(ret)
    for status in ret:
        print "%s === (%s)\n" % (status.text, status.author.screen_name)


def general_test(client, api_name):
    ret = getattr(client, api_name)();
    if (isinstance(ret, list)):
        ret = ret[0]
    for k in dir(ret):
        print "%s:%s" % (k, getattr(ret, k))



callback_uri = "http://var.grampro.com/echo"

auth_handler = auth.OAuth2()

if len(sys.argv) > 1:
    print "go to:\n" + auth_handler.get_authorize_url(callback_uri)
    code = raw_input("Input the access code:\n")
    token = auth_handler.request_access_token(code, callback_uri)
    print "access token:\n" + str(token)
    auth_handler.set_access_token(token['access_token'], 2000000000)
else:
    auth_handler.set_access_token('2.00FcT8EC0SW1Iebc1f789915BNrQ9C', 2000000000)

client = api.API(auth_handler)

for api_name in api_list:
    if api_list[api_name] == 1:
        print "testing %s..." % api_name

        func_name = "test_%s" % api_name
        if (func_name in globals()):
            globals()[func_name](client)
        else:
            general_test(client, api_name)

print "\n****************end*****************\n"
