import eventlet
eventlet.monkey_patch()
import sys, os
sys.path.append("/home/luanjunyi/poseidon/")


from util.log import _logger
from util import pbrowser

from BeautifulSoup import BeautifulSoup

BASE = "/tmp/naked/"

def get_image(url):
    _logger.debug("processing (%s)" % url)
    br = pbrowser.get_browser()
    html = br.open(url)
    soup = BeautifulSoup(html)
    href = soup.find("img", {"id": "laimagen"})['src']
    filename = os.path.basename(href)

    if os.path.exists(BASE + filename):
        _logger.debug("ignore (%s), existed" % href)
        return

    _logger.debug("will open (%s)" % href)

    img = None
    try:
        img = br.download_image(href, timeout=120).read()
    except Exception, err:
        _logger.error("failed to downloading from (%s)" % href)
        return


    with open(BASE + filename, 'w') as output:
        output.write(img)
    _logger.debug("(%s) saved" % href)

url = "http://www.iimmgg.com/gallery/g9cdec57288d68186a5a45d8cce577f98/"

br = pbrowser.get_browser()

_logger.debug("openning %s" % url)
html = br.open(url)
soup = BeautifulSoup(html)


list_div = soup.find("div", {"id": "galeria"})
all_links = list_div.findAll("a", {"href": True})
pool = eventlet.GreenPool()

for anchor in all_links:
    _logger.debug("openning link:(%s)" % anchor['href'])
    pool.spawn(get_image, anchor['href'])

pool.waitall()


