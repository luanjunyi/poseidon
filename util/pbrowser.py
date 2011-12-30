# -*- coding: utf-8 -*-
import sys, os, time, random, string, re, htmllib
from urlparse import urlparse
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../')

from log import _logger

import traceback
from third_party import mechanize
import cookielib
import urllib
from HTMLParser import HTMLParser
import BeautifulSoup
from BeautifulSoup import BeautifulSoup as BSoup

import util


def html_unescape(html):
    p = HTMLParser()
    return p.unescape(html)

def set_meta_charset(soup, encoding):
    """
    Simply find the 'charset=' string and replace the value to 'encoding'.
    """
    meta_processed = False
    for meta in soup.findAll('meta'):
        if meta.has_key('content'):
            content = meta['content']
            match = soup.CHARSET_RE.search(content)
            if match:
                def rewrite(match):
                    return match.group(1) + encoding
                newAttr = soup.CHARSET_RE.sub(rewrite, content)
                meta['content'] = newAttr
                _logger.debug('new attr:%s' % newAttr)
                meta_processed = True
                break

    if not meta_processed:
        meta = BeautifulSoup.Tag(soup, 'meta', attrs={'http-equiv': 'Content-Type', 'content': 'text/html; charset=utf-8'})
        soup.insert(0, meta)

def clean_html(html, encoding):
    """
    Given html of type <str>. This function alcomplish following stuff:
    1. Remove non-content tags such as HTML comment, declaration, CData etc
    2. Adjust the encoding so that it's consistent with charset meta tag.
       If there's no such tag, use UTF8 and add <meta ... content="charset='UTF8'" />.
       As for now, we always return UTF8 encoded string and set meta charset to UTF8
    3. Various clean up: remove <meta charset="">, change '·' to ' '  
    """

    # remove junks dealing with IE6
    ptn = re.compile(r'<!–+\[.+?\]>.+?<!\[endif\]–+>', re.S)
    html = ptn.sub('', html)
    # remove junks like <meta charset="gbk" />
    ptn = re.compile(r'<meta charset=.*>', re.I)
    html = ptn.sub('', html)

    try:
        soup = BSoup(util.convert_to_utf8(html, encoding), fromEncoding='utf-8')
    except Exception, err:
        _logger.error('Failed to create BeautifulSoup:%s' % err)
        return ""

    comments = soup.findAll(text = lambda text:
                                isinstance(text, BeautifulSoup.Comment)
                            or isinstance(text, BeautifulSoup.Declaration)
                            or isinstance(text, BeautifulSoup.CData)
                            or isinstance(text, BeautifulSoup.ProcessingInstruction))
    [comment.extract() for comment in comments]
    c = soup.findAll('script')
    [i.extract() for i in c]
    s = soup.findAll('style')
    [i.extract() for i in s]
    s = soup.findAll('img')
    [i.extract() for i in s]

    # set charset meta tag
    set_meta_charset(soup, 'utf-8')
    html = soup.prettify('utf-8')

    # change '·' to SPACE
    html = html.replace('·', ' ')

    return html


def extract_content(html, selenium):
    # safe to temp file and open with selenium
    escaped = []
    path = util.dump2file_with_date(content=html, ext='html')
    url = "file://%s/%s" % (os.path.abspath('.'), path)
    _logger.debug('opening %s' % url)
    selenium.open(url)
    text = selenium.get_body_text()
    text = html_unescape(text)
    text = text.replace('\r', '\n')
    text = re.sub(r'\s{3, }', '\n', text)
    text = text.split('\n')     # 

    os.system('rm %s' % path)

    escaped = []
    for i in text:
        i = i.strip()
        for para in i.split('\n'):
            para = para.strip()
            if len(para) > 0:
                escaped.append(para)
    return escaped

    
def extract_main_body(url, selenium, encoding):
    br = get_browser()
    _logger.debug('opening %s' % url)
    br.open(url)
    html = br.get_html_source()
    _logger.debug('removing non-content tags')
    html = clean_html(html, encoding) # html is now a utf-8 string
    if html == '':
        _logger.error('clean_html failed, aborting')
        return ''

    # use meta description, if any
    # soup = BSoup(html, fromEncoding='utf-8')
    # desc = soup.find('meta', attrs={'name': 'description'})
    # if desc != None and hasattr(desc, 'content') and util.chinese_charactor_count(desc['content'].strip()) > 35:
    #     _logger.debug('use meta description as main body')
    #     return html_unescape(desc['content'].strip())

    contents = extract_content(html, selenium)
    limit = 70
    while limit >= 50:
        for content in contents:
            char_count = util.chinese_charactor_count(content.strip())
            if char_count > limit and content[:140].count(' ') <= 3:
                _logger.debug('found main body(%s), char count:%d' % (content.encode('utf-8'), char_count))
                return content
        limit -= 5
    return ''

# Get the level of <h1>-<h6>, return -1 if not heading
def _get_heading_level(name):
    if len(name) != 2 or (name[0] != 'h' and name[0] != 'H'):
        return -1
    try:
        return int(name[1])
    except:
        return -1

# True if prefer tag a to tag b
def _prefer_tag(a, b):
    if b == None:
        return True
    if a == None:
        return False

    if not hasattr(a, 'name'):
        a = a.parent
    if not hasattr(b, 'name'):
        b = b.parent

    if b == None:
        return True
    if a == None:
        return False

    # <title> is bad for us
    if b.name == u'title':
        return True
    # we prefer <h1>-<h6> to others
    if _get_heading_level(a.name) != -1:
        if  _get_heading_level(b.name) == -1:
            return True
        return _get_heading_level(a.name) < _get_heading_level(b.name)

    return False

def _find_tag_by_best_match(soup, target):
    match_tag = None
    best_ratio = 0
    for tag in soup.findAll(text=True):
        ratio = util.match_ratio(target, html_unescape(unicode(tag).strip()))

        if ratio > 0.9 and _prefer_tag(tag, match_tag):
            _logger.debug('>0.9 match and prefer tag:%s,(%f)' % (str(tag),ratio))
            best_ratio = ratio
            match_tag = tag
        elif ratio > best_ratio + 0.3:
            _logger.debug('>best+0.3 tag:%s,(%f)' % (str(tag),ratio))
            best_ratio = ratio
            match_tag = tag
        elif ratio >= best_ratio - 0.1 and _prefer_tag(tag, match_tag):
            _logger.debug('>best-0.1 and prefer tag:%s,(%f)' % (str(tag),ratio))
            best_ratio = ratio
            match_tag = tag
            
    if match_tag == None or best_ratio < 0.7:
        _logger.debug('No match')
        return None

    _logger.debug('best match ratio:%f' % best_ratio)
    return match_tag

def _not_thin_banner(data):
    from StringIO import StringIO
    import Image
    pic = Image.open(StringIO(data))
    if pic.size[0] > pic.size[1]:
        big = pic.size[0]
        small = pic.size[1]
    else:
        big = pic.size[1]
        small = pic.size[0]
    ratio = float(big) / float(small)
    _logger.debug('image demension: (%d / %d = %f)' % (big, small, ratio))
    return ratio < 2.5

def fix_malformated_tags(html):
    # fix unclosed <img>
    ptn = re.compile(r'(<img.*?src=[^>]*?)(?<!/)>', re.I)
    html, count = ptn.subn(r'\1 />', html)
    _logger.debug('%d non closing <img> fixed' % count)

    # fix unquoted alt attributes
    ptn = re.compile(r'alt=(?!("|\'))(.+?) ', re.I)
    html, count = ptn.subn('alt="\2" ', html)

    return html

def get_main_image_with_hint(url, hint, selenium, hint_encoding='utf-8'):
    _logger.debug('hint=(%s), opening %s' % (hint, url))

    if hint == '':
        _logger.debug('hint is None, will return nothing')
        return None, ''
    if type(hint) == str:
        hint = util.convert_to_utf8(hint)
        hint = hint.decode('utf-8')

    # prepare selenium
    _logger.debug('opening %s in Selenium' % url)
    selenium.open(url)

    html = selenium.get_html_source()
    html = fix_malformated_tags(html)

    soup = BSoup(html, fromEncoding='utf-8')
    hint_tag = _find_tag_by_best_match(soup, hint)
    
    if hint_tag == None:
        _logger.debug('no hint is found')
        return None, ''

    tag = hint_tag.parent
    _logger.debug('found matching tag: %s(%s)' % (str(tag)[:200], str(tag.attrs)))


    # get left position of matching 
    xpath = u'//%s[text()="%s"]' % (tag.name, tag.text)
    matching_tag_left = selenium.get_element_position_left(xpath)
    matching_tag_top = selenium.get_element_position_top(xpath)
    matching_tag_width = selenium.get_element_width(xpath)

    _logger.debug('matching tag position:(left: %d, top: %d)'
                  % (matching_tag_left, matching_tag_top))

    image_data = None
    image_url = ''
    found_image = False

    
    br = get_browser()

    for img in soup.findAll('img', src=True):
        xpath = u'//img[@src="%s"]' % img['src']
        try:
            left = selenium.get_element_position_left(xpath)
            top = selenium.get_element_position_top(xpath)
        except Exception, err:
            _logger.error('failed to get positon for element, xpath=(%s): %s'
                          % (xpath, err))
            continue
        if top < matching_tag_top or left > matching_tag_left + matching_tag_width / 2:
            _logger.debug('ignoring img for bad pos, (top:%d, left:%d, url:%s)' % (top, left, img['src']))
            continue

        try:
            image_data = br.download_image(img['src'], base_url = url).read()
            import Image
            from StringIO import StringIO
            pic = Image.open(StringIO(image_data))
            pic_size = pic.size[0] * pic.size[1]
            _logger.debug('got image(%d, %s)' % (pic_size, img['src']))
        except Exception, err:
            _logger.error('failed to download image(%s): %s' % (img['src'], err))
            continue

        if pic_size >= 60000 and _not_thin_banner(image_data):
            _logger.debug('selected main image, url: (%s), size: (%d)' % (img['src'], pic_size))
            image_url = img['src']
            found_image = True
            break
        
    if found_image:
        return image_data, abs_url(url, image_url)
    else:
        return None, ''

    

def get_main_image_with_hint_old(url, hint, hint_encoding='utf-8'):
    max_layer_count = 3

    if hint == '':
        _logger.debug('hint is None, will return nothing')
        return None, ''
    if type(hint) == str:
        hint = util.convert_to_utf8(hint)
        hint = hint.decode('utf-8')
    br = get_browser()
    _logger.debug('hint=(%s), opening %s' % (hint.encode('utf-8'), url.encode('utf-8')))
    br.open(url)
    html = br.get_html_source()
    html = util.convert_to_utf8(html, hint_encoding)
    html = fix_malformated_tags(html)

    soup = BSoup(html, fromEncoding='utf-8')
    hint_tag = _find_tag_by_best_match(soup, hint)
    
    if hint_tag == None:
        _logger.debug('no hint is found')
        return None, ''

    tag = hint_tag.parent
    _logger.debug('found matching tag: %s(%s)' % (str(tag)[:200], str(tag.attrs)))
    image_data = None
    image_url = ''
    found_image = False

    layer_count = 0
    while tag != None and not found_image and layer_count <= max_layer_count:
        _logger.debug('trying tag(%s), %s' % (tag.name, tag.attrs))
        imgs = tag.findAll('img', src=re.compile('(.jpg|.png|.jpeg|.gif)$'))
        for img in imgs:
            try:
                #print 'browser url:' + br.geturl()
                image_data = br.download_image(img['src']).read()
                import Image
                from StringIO import StringIO
                pic = Image.open(StringIO(image_data))
                pic_size = pic.size[0] * pic.size[1]
                _logger.debug('got image(%d, %s)' % (pic_size, img['src']))
            except Exception, err:
                _logger.error('failed to download image(%s): %s' % (img['src'], err))
                continue

            if pic_size >= 100000 and _not_thin_banner(image_data):
                _logger.debug('selected main image, level: %d, url: (%s), size: (%d)' % (layer_count, img['src'], pic_size))
                image_url = img['src']
                found_image = True
                break
        if not (hasattr(tag, 'name') and (tag.name == 'td' or tag.name == 'tr')):
            layer_count += 1
        tag = tag.parent


    if found_image:
        return image_data, abs_url(url, image_url)
    else:
        return None, ''

    # print tag.name, tag.attrs
    # print tag.find('img')

def get_main_image(url):
    br = get_browser()
    html = br.open(url).read()
    soup = BSoup(html)
    max_img = None
    max_size = 0
    max_url = None
    all_img = soup.findAll('img', src=re.compile("(.jpg|.png)$"))
    _logger.debug('fetching %d condidate images' % len(all_img))
    for img in all_img:
        try:
            image_data = br.download_image(img['src']).read()
            image_size = len(image_data)
            if max_size < image_size:
                max_img = image_data
                max_url = img['src']
                max_size = image_size
        except Exception, err:
            _logger.error('error when downloading(%s):%s' % (img['src'], err))
        else:
            _logger.debug("%s:%d" % (img['src'], image_size))

    return max_img, abs_url(url, max_url)

def abs_url(base_url, url):
    url = url.strip()
    if url[:4] == 'http':
        return url

    _logger.debug('relative url:(%s), baseurl:(%s)' % (url, base_url))

    if url[0] == '/':
        basep = urlparse(base_url)
        if basep.path != '':
            base_url = base_url.replace(basep.path, '/')
        if base_url[-1] != '/':
            base_url += '/'
        _logger.debug('baseurl changed to %s' % base_url)
        url = url[1:]
    else:
        b = re.search('.+://.+/', base_url)
        if b != None:
            base_url = b.group()
        else:
            base_url = base_url + '/'
        _logger.debug('baseurl changed to %s' % base_url)

    url = base_url + url
    _logger.debug('got absolute url:%s' % url)
    return url

def get_all_href(url, encoding = 'utf-8'):
    br = get_browser()
    _logger.debug('opening url(%s) for links' % url)
    br.open(url)
    _logger.debug('loaded (%s)' % url)
    html = br.get_html_source()
    soup = BSoup(util.convert_to_utf8(html, encoding), fromEncoding='utf-8')
    
    all_href = []
    for a in soup.findAll('a', href=True):
        a['href'] = br.abs_url(a['href'])
        all_href.append(a)
    return all_href
    


class ParadomoBrowser(mechanize.Browser):
    def __init__(self, factory=None, history=None, request_class=None):
        mechanize.Browser.__init__(self, factory, history, request_class)

    def download_image(self, url, base_url = None, timeout = 30):
        try:
            if base_url != None:
                referer = base_url
            else:
                referer = self.geturl()
            #print 'verified browser url:' + referer
            url = abs_url(referer, url)
            request = mechanize.Request(url=url, headers={'referer':referer})
        except Exception, err:
            _logger.debug('download image without set referer: %s', err)
            request = mechanize.Request(url=url)
        return self.open_novisit(request, timeout=timeout)

    def abs_url(self, url):
        try:
            referer = self.geturl()
            return abs_url(referer, url)
        except Exception, err:
            _logger.debug('failed to get absolute url: %s' % err)
            return url

    def get_html_source(self):
        try:
            html = self.response().read()
            status = self.response().info()
            if status.has_key('content-encoding'):
                if status['content-encoding'].lower() == 'gzip':
                    _logger.debug('need to extract gzip')
                    import gzip
                    from StringIO import StringIO
                    html = gzip.GzipFile(fileobj = StringIO(html)).read()
                else:
                    raise Exception('unknown content-encoding header: %s' % status['content-encoding'])
        except Exception, err:
            raise err
        return html

def get_browser():

    # Browser
    pbrowser = ParadomoBrowser(mechanize.RobustFactory())

    # Cookie Jar
    _cj = cookielib.LWPCookieJar()
    pbrowser.set_cookiejar(_cj)

    # Browser options
    pbrowser.set_handle_equiv(True)
    pbrowser.set_handle_redirect(True)
    pbrowser.set_handle_referer(True)
    pbrowser.set_handle_robots(False)

    # Follows refresh 0 but not hangs on refresh > 0
    pbrowser.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)

    # Want debugging messages
    # pbrowser.set_debug_http(True)
    #pbrowser.set_debug_redirects(True)
    #pbrowser.set_debug_responses(True)

    # User-Agent (this is cheating, ok?)
    pbrowser.addheaders = [('User-agent',\
                                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1'),
                           ('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'),
                           ('Accept-Language', 'en-us,en;q=0.5'),
                           ('Accept-Charset', 'utf-8;q=0.7,*;q=0.7'),
                           ('Keep-Alive', '115'),
                           ('Connection','keep-alive'),]
    pbrowser.cj = _cj
    return pbrowser


def ask_google(keywords, needed, proxy=None, callback=None, terminate=None, sleep_min=1, sleep_max=3):
    keywords = urllib.quote_plus(keywords)
    random.seed()
    if needed > 1000:
        needed = 1000
    br = get_browser()
    if proxy != None:
        br.set_proxies({'http': proxy, 'https': proxy})
    results = set()
    url = 'http://www.google.com/search?q=%s' % keywords
    current_page = 1
    # Kick off searching
    fail_num = 0
    _logger.info('searching [%s] for %d results from %s' % (keywords, needed, url))
    while fail_num < 5:
        try:
            response = br.open(url, timeout=5.0)
            break
        except Exception, err:
            _logger.error('initial fetching failed(%s): %s' % (url, err))
            fail_num += 1
    if fail_num == 5:
        _logger.error('permanently failed')
        return []
    soup = BSoup(response.read())
    results.update(set([li.find('a')['href'] for li in soup.findAll('li', 'g')]))

    if callback != None:
        for item in results:
            callback(item)

    if terminate != None:
        for index, item in enumerate(results):
            if terminate(item):
                return {'page': current_page, 'url': url, 'rank': index + 1}
                

    current_page += 1

    html = ''
    while len(results) < needed:
        _logger.debug('fetching page %d' % current_page)
        fail_num = 0
        # sleep
        sleep = random.randint(sleep_min, sleep_max)
        _logger.debug('sleeping for %d secs(%d results)' % (sleep, len(results)))
        time.sleep(sleep)

        try:
            link = br.find_link(predicate=lambda link: dict(link.attrs).has_key('id') and dict(link.attrs)['id'] == 'pnnext')
        except Exception, err:
            _logger.debug('reached SERPs end, url:%s' % (br.geturl()))
            break

        while fail_num < 5:
            try:
                response = br.follow_link(predicate=lambda link: dict(link.attrs).has_key('id') and dict(link.attrs)['id'] == 'pnnext')
                break
            except Exception, err:
                _logger.error('page %d fetching failed, url:(%s): %s' % (current_page, link.absolute_url, err.message))
                if br.response() != None and br.response().code == 503:
                    _logger.error('503 encoutered, I\'ll quit and the sever should take a rest too')
                    fail_num = 5
                    break
                fail_num += 1
        if fail_num == 5:
            _logger.error('permanently failed')
            break

        fail_num = 0

        html = br.response().read()
        try:
            # Parse the page
            soup = BSoup(response.read())
            new_urls = set([li.find('a')['href'] for li in soup.findAll('li', 'g')])
            duplicate_result = new_urls & results
            if len(duplicate_result) != 0:
                _logger.debug('%d duplicated url detected on page %d:' % (len(duplicate_result), current_page))
                for url in duplicate_result:
                    _logger.debug('duplicated:' + url)

            new_items = new_urls - results
            if callback != None:
                for item in new_items:
                    callback(item)

            if terminate != None:
                for index, item in enumerate(new_items):
                    if terminate(item):
                        return {'page': current_page, 'url': br.geturl(), 'rank': len(results) + index}
            results.update(new_urls)
            # Get next page url
        except Exception, err:
            _logger.error('failed parsing %s, will ignore:%s' % (url, err))
        current_page += 1

    _logger.debug('%d pages processed' % current_page)
    if terminate != None:
        return {'page': current_page, 'url': br.geturl(), 'rank': 0}
    return list(results)[:needed]

def find_rank(domain, keyword):
    def check_item(url):
        if url.find('/interstitial?url=') != -1:
            url = url[len('/interstitial?url='):]
        pos = urlparse(url).netloc.find(domain)
        return  pos != -1 and (pos == 0 or urlparse(url).netloc[pos - 1] == '.')

    _logger.debug('searching rank, keyword: (%s), domain: (%s)' % (keyword, domain))

    return ask_google(keyword, 1000, terminate=check_item)
    
if __name__ == "__main__":
    print find_rank(sys.argv[1], sys.argv[2])
    # result = ask_google(sys.argv[1], int(sys.argv[2]))
    # with open(sys.argv[1] + '.' + sys.argv[2], 'w') as output:
    #     output.write('\n'.join(result))
