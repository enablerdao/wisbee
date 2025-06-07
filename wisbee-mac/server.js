const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = 8899;
const OLLAMA_HOST = 'http://localhost:11434';

// MIME types
const mimeTypes = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon'
};

// Create server
const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    // Handle OPTIONS
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    const parsedUrl = url.parse(req.url);
    const pathname = parsedUrl.pathname;

    // API proxy
    if (pathname.startsWith('/api/')) {
        proxyToOllama(req, res, pathname);
        return;
    }

    // Serve static files
    let filePath = path.join(__dirname, pathname === '/' ? 'index.html' : pathname);
    
    fs.access(filePath, fs.constants.F_OK, (err) => {
        if (err) {
            res.writeHead(404, { 'Content-Type': 'text/html' });
            res.end('<h1>404 Not Found</h1>');
            return;
        }

        const extname = path.extname(filePath).toLowerCase();
        const contentType = mimeTypes[extname] || 'application/octet-stream';

        fs.readFile(filePath, (error, content) => {
            if (error) {
                res.writeHead(500);
                res.end('Internal Server Error');
                return;
            }
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        });
    });
});

// Proxy to Ollama
function proxyToOllama(req, res, pathname) {
    const ollamaUrl = OLLAMA_HOST + pathname;
    console.log(`Proxying ${req.method} request to: ${ollamaUrl}`);
    
    if (req.method === 'GET') {
        // Simple GET request
        http.get(ollamaUrl, (ollamaRes) => {
            console.log(`Ollama response status: ${ollamaRes.statusCode}`);
            res.writeHead(ollamaRes.statusCode, ollamaRes.headers);
            ollamaRes.pipe(res);
        }).on('error', (err) => {
            console.error('Ollama GET connection error:', err.message, err.code);
            res.writeHead(503, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ 
                error: 'Cannot connect to Ollama. Make sure Ollama is running on localhost:11434',
                details: err.message
            }));
        });
    } else if (req.method === 'POST') {
        // Handle POST with streaming
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        
        req.on('end', () => {
            const options = {
                hostname: 'localhost',
                port: 11434,
                path: pathname,
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(body)
                }
            };

            const ollamaReq = http.request(options, (ollamaRes) => {
                // Check if streaming
                let requestData;
                try {
                    requestData = JSON.parse(body);
                } catch (e) {
                    requestData = {};
                }

                if (requestData.stream) {
                    res.writeHead(ollamaRes.statusCode, {
                        'Content-Type': 'application/x-ndjson',
                        'Transfer-Encoding': 'chunked'
                    });
                } else {
                    res.writeHead(ollamaRes.statusCode, ollamaRes.headers);
                }

                ollamaRes.pipe(res);
            });

            ollamaReq.on('error', (err) => {
                console.error('Ollama connection error:', err);
                res.writeHead(503, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ 
                    error: 'Cannot connect to Ollama. Make sure Ollama is running on localhost:11434' 
                }));
            });

            ollamaReq.write(body);
            ollamaReq.end();
        });
    }
}

// Start server
server.listen(PORT, () => {
    console.log(`🚀 Wisbee Server running on http://localhost:${PORT}`);
    console.log(`📁 Serving files from: ${__dirname}`);
    console.log(`🔗 Proxying Ollama API from: ${OLLAMA_HOST}`);
});

// Export for Electron
module.exports = { server };