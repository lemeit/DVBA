#!/usr/bin/env python3
"""
DVBA Zona VI - Servidor HTTP local
Sirve correctamente los headers necesarios para PWA / Service Worker
"""
import http.server
import socketserver
import os

PORT = 8080

class DVBAHandler(http.server.SimpleHTTPRequestHandler):
    # Map extensiones a MIME types críticos para PWA
    extensions_map = {
        '': 'application/octet-stream',
        '.html': 'text/html; charset=utf-8',
        '.htm':  'text/html; charset=utf-8',
        '.css':  'text/css',
        '.js':   'application/javascript',
        '.json': 'application/json',
        '.png':  'image/png',
        '.jpg':  'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.ico':  'image/x-icon',
        '.svg':  'image/svg+xml',
        '.webp': 'image/webp',
        '.woff': 'font/woff',
        '.woff2':'font/woff2',
        '.bat':  'application/octet-stream',
        '.geojson': 'application/json',
    }

    def end_headers(self):
        # Headers necesarios para Service Worker y PWA
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Access-Control-Allow-Origin', '*')
        # Permite instalar SW en HTTP localhost
        self.send_header('Service-Worker-Allowed', '/')
        super().end_headers()

    def log_message(self, format, *args):
        # Log limpio sin spam
        code = args[1] if len(args) > 1 else '?'
        path = args[0].split(' ')[1] if ' ' in str(args[0]) else str(args[0])
        print(f"  [{code}] {path}")

if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    with socketserver.TCPServer(("", PORT), DVBAHandler) as httpd:
        httpd.allow_reuse_address = True
        print(f"\n  DVBA Servidor HTTP - Puerto {PORT}")
        print(f"  ─────────────────────────────────────────")
        print(f"  APP ESCRITORIO")
        print(f"  http://localhost:{PORT}/dvba_zona6.html")
        print(f"\n  APP CAMPO (PWA)")
        print(f"  http://localhost:{PORT}/dvba_campo.html")
        print(f"  ─────────────────────────────────────────")
        print(f"  Ctrl+C para detener\n")
        httpd.serve_forever()
