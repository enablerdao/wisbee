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
    
    def do_POST(self):
        if self.path == '/api/generate' or self.path.startswith('/api/'):
            # Handle all API requests
            ollama_path = self.path
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                # Parse request to check if streaming is enabled
                request_data = json.loads(post_data)
                
                # Forward request to Ollama with streaming
                response = requests.post(
                    f'http://localhost:11434{ollama_path}',
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

    def do_GET(self):
        if self.path == '/':
            self.path = '/ollama-webui.html'
        elif self.path.startswith('/api/'):
            # Proxy GET requests to Ollama API
            try:
                response = requests.get(f'http://localhost:11434{self.path}')
                self.send_response(response.status_code)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(response.content)
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                error_response = json.dumps({'error': str(e)})
                self.wfile.write(error_response.encode())
            return
        elif self.path == '/config.json':
            # Load config file if exists, otherwise use default
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
        return super().do_GET()

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