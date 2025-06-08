from http.server import BaseHTTPRequestHandler
import json
import os
import urllib.request
import urllib.parse
import urllib.error

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/tags':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            # Return demo models for the landing page
            demo_response = {
                "models": [
                    {
                        "name": "llama3.2:latest",
                        "size": 2048000000,
                        "digest": "demo"
                    },
                    {
                        "name": "gemma2:2b", 
                        "size": 1536000000,
                        "digest": "demo"
                    },
                    {
                        "name": "qwen2.5:0.5b",
                        "size": 512000000,
                        "digest": "demo"
                    }
                ]
            }
            self.wfile.write(json.dumps(demo_response).encode())
            return
            
        # Health check
        elif self.path == '/api/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok", "message": "Wisbee API is running"}).encode())
            return
            
        # Default response
        self.send_response(404)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps({"error": "Not found"}).encode())

    def do_POST(self):
        if self.path == '/api/generate':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            # Demo response for the landing page
            demo_response = json.dumps({
                "response": "これはWisbeeのデモレスポンスです。実際の使用では、お使いのローカルマシンでOllamaが動作し、高速でプライベートなAI応答を生成します。",
                "done": True
            })
            self.wfile.write(demo_response.encode())
            return
            
        # Default response for other POST requests
        self.send_response(404)
        self.send_header('Content-type', 'application/json')  
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps({"error": "Not found"}).encode())

    def do_OPTIONS(self):
        # Handle CORS preflight requests
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()