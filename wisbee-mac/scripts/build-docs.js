// 📚 Build Documentation
const fs = require('fs');
const path = require('path');

function buildDocs() {
  const docsDir = path.join(__dirname, '../docs-dist');
  const readmePath = path.join(__dirname, '../README.md');
  
  if (!fs.existsSync(docsDir)) {
    fs.mkdirSync(docsDir, { recursive: true });
  }
  
  // Read README.md
  let readmeContent = '';
  if (fs.existsSync(readmePath)) {
    readmeContent = fs.readFileSync(readmePath, 'utf-8');
  }
  
  // Convert markdown to HTML (simple conversion)
  const htmlContent = markdownToHTML(readmeContent);
  
  const indexHTML = `
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🐝 Wisbee Documentation</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            color: #333;
        }
        h1, h2, h3 { color: #10a37f; }
        code {
            background: #f4f4f4;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: Monaco, monospace;
        }
        pre {
            background: #f4f4f4;
            padding: 1rem;
            border-radius: 5px;
            overflow-x: auto;
        }
        .logo {
            text-align: center;
            font-size: 3rem;
            margin: 2rem 0;
        }
    </style>
</head>
<body>
    <div class="logo">🐝</div>
    ${htmlContent}
</body>
</html>
  `;
  
  fs.writeFileSync(path.join(docsDir, 'index.html'), indexHTML);
  
  // Copy assets if they exist
  const assetsDir = path.join(__dirname, '../assets');
  if (fs.existsSync(assetsDir)) {
    const docsAssetsDir = path.join(docsDir, 'assets');
    if (!fs.existsSync(docsAssetsDir)) {
      fs.mkdirSync(docsAssetsDir);
    }
    
    // Copy icon files
    const files = fs.readdirSync(assetsDir);
    files.forEach(file => {
      if (file.endsWith('.png') || file.endsWith('.svg') || file.endsWith('.ico')) {
        fs.copyFileSync(
          path.join(assetsDir, file),
          path.join(docsAssetsDir, file)
        );
      }
    });
  }
  
  console.log(`📚 Documentation built in: ${docsDir}`);
}

function markdownToHTML(markdown) {
  return markdown
    // Headers
    .replace(/^### (.*$)/gm, '<h3>$1</h3>')
    .replace(/^## (.*$)/gm, '<h2>$1</h2>')
    .replace(/^# (.*$)/gm, '<h1>$1</h1>')
    // Bold
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    // Italic
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    // Code blocks
    .replace(/```([\\s\\S]*?)```/g, '<pre><code>$1</code></pre>')
    // Inline code
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    // Links
    .replace(/\\[(.*?)\\]\\((.*?)\\)/g, '<a href="$2">$1</a>')
    // Line breaks
    .replace(/\\n/g, '<br>')
    // Paragraphs
    .split('\\n\\n').map(p => p.trim() ? `<p>${p}</p>` : '').join('\\n');
}

if (require.main === module) {
  buildDocs();
}

module.exports = buildDocs;