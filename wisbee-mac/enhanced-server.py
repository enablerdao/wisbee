#!/usr/bin/env python3
"""
Enhanced web server for Ollama Web UI with full API proxy support
"""

import json
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse
import requests

class EnhancedOllamaHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()
    
    def do_GET(self):
        # Handle Ollama API endpoints
        if self.path.startswith('/api/'):
            self.proxy_to_ollama()
        else:
            # Default GET handler for serving files
            super().do_GET()
    
    def do_POST(self):
        # Handle Ollama API endpoints
        if self.path.startswith('/api/'):
            self.proxy_to_ollama()
        else:
            self.send_error(405, "Method Not Allowed")
    
    def proxy_to_ollama(self):
        """Proxy requests to Ollama API"""
        ollama_url = f'http://localhost:11434{self.path}'
        
        try:
            if self.command == 'GET':
                response = requests.get(ollama_url)
                
                self.send_response(response.status_code)
                for header, value in response.headers.items():
                    if header.lower() not in ['content-length', 'connection', 'content-encoding']:
                        self.send_header(header, value)
                self.end_headers()
                self.wfile.write(response.content)
                
            elif self.command == 'POST':
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length) if content_length > 0 else b''
                
                # Check if streaming is requested
                try:
                    request_data = json.loads(post_data) if post_data else {}
                    is_streaming = request_data.get('stream', False)
                except:
                    is_streaming = False
                    request_data = {}
                
                # Make request to Ollama
                response = requests.post(
                    ollama_url,
                    data=post_data,
                    headers={'Content-Type': 'application/json'},
                    stream=is_streaming
                )
                
                self.send_response(response.status_code)
                
                if is_streaming:
                    # Handle streaming response
                    self.send_header('Content-Type', 'application/x-ndjson')
                    self.send_header('Transfer-Encoding', 'chunked')
                    self.end_headers()
                    
                    for line in response.iter_lines():
                        if line:
                            chunk = line + b'\n'
                            self.wfile.write(f'{len(chunk):X}\r\n'.encode())
                            self.wfile.write(chunk)
                            self.wfile.write(b'\r\n')
                            self.wfile.flush()
                    
                    # Send final chunk
                    self.wfile.write(b'0\r\n\r\n')
                else:
                    # Non-streaming response
                    for header, value in response.headers.items():
                        if header.lower() not in ['content-length', 'connection', 'content-encoding']:
                            self.send_header(header, value)
                    self.end_headers()
                    self.wfile.write(response.content)
                    
        except requests.exceptions.ConnectionError:
            error_response = {
                'error': 'Cannot connect to Ollama. Make sure Ollama is running on localhost:11434'
            }
            self.send_response(503)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(error_response).encode())
        except Exception as e:
            error_response = {'error': str(e)}
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(error_response).encode())

def run_server(port=8899):
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    server_address = ('', port)
    httpd = HTTPServer(server_address, EnhancedOllamaHandler)
    print(f"🚀 Enhanced Ollama Web UI Server running on http://localhost:{port}")
    print(f"📁 Serving files from: {os.getcwd()}")
    print(f"🔗 Proxying Ollama API from: http://localhost:11434")
    httpd.serve_forever()

if __name__ == '__main__':
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8899
    run_server(port)