#!/usr/bin/env python3
"""
Smart Ollama Web Server with automatic port detection
Finds available port and handles multiple service instances
"""

import json
import os
import socket
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse
import requests

# Wisbee-themed port numbers (bee-related: 8888 looks like BBBB)
PREFERRED_PORTS = [
    8888,  # Main port (looks like BBBB for Bee)
    7777,  # Lucky sevens
    9999,  # Premium port
    8899,  # Original default
    8080,  # Common fallback
    8000,  # Another common port
]

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
            ollama_path = self.path
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                request_data = json.loads(post_data)
                
                response = requests.post(
                    f'http://localhost:11434{ollama_path}',
                    data=post_data,
                    headers={'Content-Type': 'application/json'},
                    stream=request_data.get('stream', False)
                )
                
                self.send_response(response.status_code)
                
                if request_data.get('stream', False):
                    self.send_header('Content-Type', 'application/x-ndjson')
                    self.send_header('Transfer-Encoding', 'chunked')
                    self.end_headers()
                    
                    for line in response.iter_lines():
                        if line:
                            self.wfile.write(line + b'\n')
                            self.wfile.flush()
                else:
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
            # Check which UI files are available - prioritize ultimate version
            if os.path.exists('wisbee-ultimate.html'):
                self.path = '/wisbee-ultimate.html'
            elif os.path.exists('wisbee-enhanced.html'):
                self.path = '/wisbee-enhanced.html'
            elif os.path.exists('index.html'):
                self.path = '/index.html'
            elif os.path.exists('ollama-webui.html'):
                self.path = '/ollama-webui.html'
            else:
                self.send_response(200)
                self.send_header('Content-Type', 'text/html')
                self.end_headers()
                self.wfile.write(b"<h1>Wisbee Server Running</h1><p>No UI files found.</p>")
                return
        elif self.path == '/download' or self.path == '/download/':
            # Serve download page from wisbee directory
            if os.path.exists('wisbee/download.html'):
                self.path = '/wisbee/download.html'
            else:
                self.send_response(404)
                self.send_header('Content-Type', 'text/html')
                self.end_headers()
                self.wfile.write(b"<h1>Download page not found</h1>")
                return
        elif self.path.startswith('/api/'):
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
                    },
                    "server": {
                        "preferredPorts": PREFERRED_PORTS
                    }
                }
                self.wfile.write(json.dumps(default_config).encode())
                return
        return super().do_GET()

def is_port_available(port):
    """Check if a port is available for binding"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('', port))
            return True
    except OSError:
        return False

def find_available_port(preferred_ports=None):
    """Find first available port from preferred list"""
    if preferred_ports is None:
        preferred_ports = PREFERRED_PORTS
    
    for port in preferred_ports:
        if is_port_available(port):
            return port
    
    # If no preferred ports available, let OS assign one
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        return s.getsockname()[1]

def run_server(port=None):
    """Run server on specified port or find available one"""
    if port is None:
        port = find_available_port()
    elif not is_port_available(port):
        print(f"⚠️  Port {port} is already in use!")
        port = find_available_port()
        print(f"📍 Using alternative port: {port}")
    
    server_address = ('', port)
    httpd = HTTPServer(server_address, OllamaProxyHandler)
    
    print(f"🐝 Wisbee Server (Ollama WebUI)")
    print(f"🚀 Running at http://localhost:{port}")
    print(f"📁 Open http://localhost:{port} in your browser")
    print(f"🛑 Press Ctrl+C to stop\n")
    
    # Save current port to file for other services
    with open('.current_port', 'w') as f:
        f.write(str(port))
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 Server stopped")
    finally:
        # Clean up port file
        if os.path.exists('.current_port'):
            os.remove('.current_port')

if __name__ == '__main__':
    port = None
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print(f"Invalid port: {sys.argv[1]}")
            sys.exit(1)
    
    run_server(port)