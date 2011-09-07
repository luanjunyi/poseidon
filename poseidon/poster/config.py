#! /usr/bin/python2.6

__author__="johnx"
__date__ ="$Apr 1, 2011 09:30:50 AM$"

from xml.etree import ElementTree

def load_config(filename):
    return _parse_et(ElementTree.parse(filename))

def load_config_from_string(string):
    return _parse_et(ElementTree.fromstring(string))

def _parse_et(et):
    conf_sites = {}
    try:
        sites = et.findall('site')
        for site in sites:
            site_conf = {
                site.attrib['name']: {
                    'logins': [],
                    'name': site.attrib['name'],
                },
            }
            logins = site.find('logins').findall('login')
            for login in logins:
                login_conf = {}
                for property in login.findall('property'):
                    login_conf[property.attrib['name']] = property.text
                site_conf[site.attrib['name']]['logins'].append(login_conf)
            conf_sites.update(site_conf)
    except Exception, err:
        raise Exception('non valid config xml' + repr(err))

    return conf_sites

if __name__ == "__main__":
    xml_str = """<?xml version="1.0" encoding="UTF-8"?>
<sites>
	<site name="sina.com">
		<logins>
			<login>
				<property name="username">username</property>
				<property name="password">password</property>
			</login>
		</logins>
	</site>
</sites>"""
    print xml_str
    from pprint import pprint
    pprint(load_config_from_string(xml_str))
    print "...and this not for execution";
