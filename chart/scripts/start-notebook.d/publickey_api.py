from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging

class PublickeyApiServer(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()

        path = str(self.path)
        if path != "/publickey":
            return

        key_path = "/home/jovyan/.ssh/authorized_keys"
        if os.path.exists(key_path):
            with open(key_path) as f:
                keys = f.read()
            self.wfile.write(bytes(keys, "utf8"))

def run(server_class=HTTPServer, handler_class=PublickeyApiServer, port=8080):
    logging.basicConfig(level=logging.INFO)
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    logging.info('Starting publickey api server...\n')
    with open('/tmp/publickey_api.pid', 'w') as f:
        f.write(str(os.getpid()))
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        os.remove('/tmp/publickey_api.pid')
    httpd.server_close()
    logging.info('Stopping publickey api server...\n')

if __name__ == '__main__':
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
