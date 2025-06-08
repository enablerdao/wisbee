from http.server import BaseHTTPRequestHandler
import json
import os
from datetime import datetime

class handler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            # Parse request body
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            # Log analytics data (in production, you'd send to a real analytics service)
            log_entry = {
                'timestamp': datetime.utcnow().isoformat(),
                'event': data.get('event', 'unknown'),
                'platform': data.get('platform', 'unknown'),
                'version': data.get('version', 'unknown'),
                'user_agent': data.get('userAgent', ''),
                'referrer': data.get('referrer', ''),
                'ip': self.headers.get('X-Forwarded-For', self.client_address[0])
            }
            
            # In a real application, you would:
            # 1. Send to Google Analytics
            # 2. Store in a database
            # 3. Send to analytics services like Mixpanel, Amplitude, etc.
            
            print(f"Analytics Event: {json.dumps(log_entry)}")
            
            # Return success response
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
            self.send_header('Access-Control-Allow-Headers', 'Content-Type')
            self.end_headers()
            
            response = {
                'success': True,
                'message': 'Analytics event recorded'
            }
            self.wfile.write(json.dumps(response).encode())
            
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            error_response = {
                'success': False,
                'error': str(e)
            }
            self.wfile.write(json.dumps(error_response).encode())
    
    def do_OPTIONS(self):
        # Handle preflight requests
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()