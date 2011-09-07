# -*- coding: utf-8 -*-

from BaseHTTPServer import BaseHTTPRequestHandler
from BaseHTTPServer import HTTPServer
from SocketServer import ThreadingMixIn
import urlparse
import sys, os, Queue

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../../') # Paracode root
from taras import taras
from util.log import _logger


class TarasServer(BaseHTTPRequestHandler):
    def idem_get(self):
        try:
            parsed_path = urlparse.urlparse(self.path)
            message_parts = [
                    'CLIENT VALUES:',
                    'client_address=%s (%s)' % (self.client_address,
                                                self.address_string()),
                    'command=%s' % self.command,
                    'path=(%s)' % self.path,
                    'real path=(%s)' % parsed_path.path,
                    'query=%s' % parsed_path.query,
                    'request_version=%s' % self.request_version,
                    '',
                    'SERVER VALUES:',
                    'server_version=%s' % self.server_version,
                    'sys_version=%s' % self.sys_version,
                    'protocol_version=%s' % self.protocol_version,
                    'server_name=%s' % self.server.name,
                    '',
                    'HEADERS RECEIVED:',
                    ]
            for name, value in sorted(self.headers.items()):
                message_parts.append('%s=%s' % (name, value.rstrip()))
            message_parts.append('')
            message = '\r\n'.join(message_parts)
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(message)
            return
        except Exception, err:
            print err

    def xpath_get(self, parsed):
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        get = urlparse.parse_qs(parsed.query, keep_blank_values=True)
        url = get['url'][0]
        title_xpath = get['title_xpath'][0]
        image_xpath = get['image_xpath'][0]
        href_xpath = get['href_xpath'][0]
        content_xpath = get['content_xpath'][0]

        dae = self.server.sele_pool.get()
        try:
            tweet, image_path = dae.create_tweet_on_the_fly(url,
                                                            title_xpath,
                                                            content_xpath,
                                                            href_xpath,
                                                            image_xpath,
                                                            'utf-8')
        except Exception, err:
            _logger.error('creating tweet failed: %s' % err)
            self.wfile.write('%s^^^^^^' % err)
            return
        finally:
            self.server.sele_pool.put(dae)
        
        if image_path != "":
            os.system("mv -f %s /www/taras-ui/tmp" % image_path)
            image_path = "tmp/" + image_path
            _logger.debug('image_path: (%s)' % image_path)
        self.wfile.write("%s^^^^^^%s" % (tweet, image_path))
        

    def do_GET(self):
        parsed_path = urlparse.urlparse(self.path)
        if parsed_path.path.startswith('/idem'):
            self.idem_get()
        elif parsed_path.path.startswith('/xpath'):
            self.xpath_get(parsed_path)
        else:
            self.send_response(404)


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

if __name__ == '__main__':

    sele_pool = Queue.Queue()
    sele_num = int(sys.argv[1])
    _logger.info('spawning %d Seleniums' % sele_num)
    for i in range(sele_num):
        sele_pool.put(taras.WeiboDaemon())

    server = ThreadedHTTPServer(('', 1988), TarasServer)
    server.sele_pool = sele_pool
    server.name = 'Taras 服务器';
    print 'Starting server, use <Ctrl-C> to stop'
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        _logger.info('Got SIGINT, bye')
        for sele in sele_pool:
            sele.shutdown()

        
