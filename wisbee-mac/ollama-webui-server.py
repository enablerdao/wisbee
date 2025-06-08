#!/usr/bin/env python3
"""
Simple web server for Ollama Web UI
Handles CORS and proxies requests to Ollama API
"""

import json
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse
import requests

class OllamaProxyHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()
    
    def do_GET(self):
        # Handle download page
        if self.path == '/download' or self.path == '/download/':
            download_path = os.path.join(os.path.dirname(__file__), '..', 'wisbee-github-io', 'index.html')
            if os.path.exists(download_path):
                try:
                    with open(download_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    self.send_response(200)
                    self.send_header('Content-Type', 'text/html; charset=utf-8')
                    self.end_headers()
                    self.wfile.write(content.encode('utf-8'))
                    return
                except Exception as e:
                    self.send_response(500)
                    self.end_headers()
                    self.wfile.write(f"Error loading download page: {str(e)}".encode())
                    return
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"Download page not found")
                return
        
        # Handle API tags
        elif self.path == '/api/tags':
            try:
                response = requests.get('http://localhost:11434/api/tags')
                self.send_response(response.status_code)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(response.content)
                return
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                error_response = json.dumps({'error': str(e)})
                self.wfile.write(error_response.encode())
                return
        
        # Handle root path
        elif self.path == '/':
            self.path = '/chat.html'
        
        # Handle config.json
        elif self.path == '/config.json':
            if os.path.exists('config.json'):
                self.path = '/config.json'
            else:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                default_config = {
                    "ollama": {
                        "defaultModel": "qwen3:latest",
                        "models": ["qwen3:latest", "llama3.2:1b", "phi3:mini", "gemma3:4b", "gemma3:1b"]
                    },
                    "ui": {
                        "defaultMaxTokens": 2000,
                        "defaultTemperature": 0.7
                    }
                }
                self.wfile.write(json.dumps(default_config).encode())
                return
        
        # Default file handler
        super().do_GET()
    
    def do_POST(self):
        if self.path == '/api/generate':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                # Parse request to check if streaming is enabled
                request_data = json.loads(post_data)
                
                # Forward request to Ollama with streaming
                response = requests.post(
                    'http://localhost:11434/api/generate',
                    data=post_data,
                    headers={'Content-Type': 'application/json'},
                    stream=request_data.get('stream', False)
                )
                
                self.send_response(response.status_code)
                
                if request_data.get('stream', False):
                    # Streaming response
                    self.send_header('Content-Type', 'application/x-ndjson')
                    self.send_header('Transfer-Encoding', 'chunked')
                    self.end_headers()
                    
                    for line in response.iter_lines():
                        if line:
                            self.wfile.write(line + b'\n')
                            self.wfile.flush()
                else:
                    # Non-streaming response
                    self.send_header('Content-Type', 'application/json')
                    self.end_headers()
                    self.wfile.write(response.content)
                    
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                error_response = json.dumps({'error': str(e)})
                self.wfile.write(error_response.encode())
        else:
            self.send_response(404)
            self.end_headers()


def run_server(port=8080):
    server_address = ('', port)
    httpd = HTTPServer(server_address, OllamaProxyHandler)
    print(f"🚀 Server running at http://localhost:{port}")
    print(f"📁 Open http://localhost:{port} in your browser")
    print("Press Ctrl+C to stop the server")
    httpd.serve_forever()

if __name__ == '__main__':
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8899
    run_server(port)