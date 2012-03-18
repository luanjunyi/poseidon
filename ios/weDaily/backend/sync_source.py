import sys, os

sys.path.append("/home/luanjunyi/posiden")

from elementtree import ElementTree as ET
from db import WeeSQLAgent

agent = WeeSQLAgent('weDaily', 'junyi', 'admin123')
agent.start()
sources = ET.parse('wee_source.xml')

for source in sources.findall('source'):
    url = source.get('url')
    pr = 0
    if 'pr' in source.keys():
        pr = source.get('pr')
    tags = []
    for tag in source.findall('tag'):
        tags.append(tag.text)

    try:
        agent.add_wee_source(url, pr, tags)
    except Exception, err:
        print "add source failed: %s" % err
    
