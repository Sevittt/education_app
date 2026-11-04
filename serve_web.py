import http.server
import socketserver
import os
import sys

PORT = 5000
DIRECTORY = os.path.join(os.getcwd(), 'build', 'web')

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        # same-origin-allow-popups allows Firebase Auth / Google OAuth popups
        # to communicate credentials back to window.opener without being blocked.
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin-allow-popups')
        super().end_headers()

    def guess_type(self, path):
        if str(path).endswith('.wasm'):
            return 'application/wasm'
        if str(path).endswith('.js'):
            return 'application/javascript'
        return super().guess_type(path)

if __name__ == '__main__':
    print(f"Serving Flutter Web at http://localhost:{PORT} from {DIRECTORY}")
    socketserver.TCPServer.allow_reuse_address = True
    try:
        with socketserver.TCPServer(('0.0.0.0', PORT), CustomHandler) as httpd:
            httpd.serve_forever()
    except Exception as e:
        print(f"Server error: {e}", file=sys.stderr)
