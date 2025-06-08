// 📊 Generate Performance Report
const fs = require('fs');
const path = require('path');

function generatePerformanceReport() {
  const reportDir = path.join(__dirname, '../performance-report');
  const outputFile = path.join(reportDir, 'index.html');
  
  if (!fs.existsSync(reportDir)) {
    fs.mkdirSync(reportDir, { recursive: true });
  }
  
  // Find latest benchmark results
  const files = fs.readdirSync(reportDir)
    .filter(f => f.startsWith('benchmark-') && f.endsWith('.json'))
    .sort((a, b) => {
      const timeA = parseInt(a.match(/benchmark-(\d+)\.json/)[1]);
      const timeB = parseInt(b.match(/benchmark-(\d+)\.json/)[1]);
      return timeB - timeA;
    });
  
  let results = null;
  if (files.length > 0) {
    const latestFile = path.join(reportDir, files[0]);
    results = JSON.parse(fs.readFileSync(latestFile, 'utf-8'));
  }
  
  const html = generateReportHTML(results);
  fs.writeFileSync(outputFile, html);
  
  console.log(`📊 Performance report generated: ${outputFile}`);
}

function generateReportHTML(results) {
  const timestamp = results ? new Date(results.timestamp).toLocaleString() : 'No data';
  const summary = results?.summary || { totalTests: 0, passedTests: 0, passRate: 0 };
  
  return `
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🐝 Wisbee Performance Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            margin: 0;
            padding: 2rem;
            background: #0a0a0a;
            color: #e0e0e0;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            margin-bottom: 3rem;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 3rem;
        }
        .metric-card {
            background: #1e1e1e;
            border: 1px solid #363636;
            border-radius: 8px;
            padding: 1.5rem;
            text-align: center;
        }
        .metric-value {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        .metric-label {
            color: #9e9e9e;
            font-size: 0.875rem;
        }
        .tests-grid {
            display: grid;
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .test-card {
            background: #1e1e1e;
            border: 1px solid #363636;
            border-radius: 8px;
            padding: 1.5rem;
        }
        .test-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        .test-name {
            font-size: 1.25rem;
            font-weight: 600;
        }
        .test-status {
            font-size: 1.5rem;
        }
        .test-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
        }
        .detail-item {
            text-align: center;
        }
        .detail-value {
            font-size: 1.25rem;
            font-weight: 600;
            color: #10a37f;
        }
        .detail-label {
            color: #9e9e9e;
            font-size: 0.875rem;
        }
        .footer {
            text-align: center;
            color: #666;
            margin-top: 3rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🐝 Wisbee Performance Report</h1>
            <p>Generated: ${timestamp}</p>
        </div>
        
        <div class="summary">
            <div class="metric-card">
                <div class="metric-value">${summary.totalTests}</div>
                <div class="metric-label">Total Tests</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${summary.passedTests}</div>
                <div class="metric-label">Passed</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${summary.passRate?.toFixed(1)}%</div>
                <div class="metric-label">Pass Rate</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${summary.overallPass ? '✅' : '❌'}</div>
                <div class="metric-label">Status</div>
            </div>
        </div>
        
        <div class="tests-grid">
            ${results?.tests?.map(test => `
                <div class="test-card">
                    <div class="test-header">
                        <div class="test-name">${test.name}</div>
                        <div class="test-status">${test.pass ? '✅' : '❌'}</div>
                    </div>
                    <div class="test-details">
                        ${test.average ? `
                            <div class="detail-item">
                                <div class="detail-value">${test.average.toFixed(0)}</div>
                                <div class="detail-label">Average ${test.metric}</div>
                            </div>
                        ` : ''}
                        ${test.min ? `
                            <div class="detail-item">
                                <div class="detail-value">${test.min.toFixed(0)}</div>
                                <div class="detail-label">Min ${test.metric}</div>
                            </div>
                        ` : ''}
                        ${test.max ? `
                            <div class="detail-item">
                                <div class="detail-value">${test.max.toFixed(0)}</div>
                                <div class="detail-label">Max ${test.metric}</div>
                            </div>
                        ` : ''}
                        ${test.tokensPerSecond ? `
                            <div class="detail-item">
                                <div class="detail-value">${test.tokensPerSecond.toFixed(1)}</div>
                                <div class="detail-label">Tokens/sec</div>
                            </div>
                        ` : ''}
                        ${test.total ? `
                            <div class="detail-item">
                                <div class="detail-value">${test.total}</div>
                                <div class="detail-label">Total ${test.metric}</div>
                            </div>
                        ` : ''}
                    </div>
                </div>
            `).join('') || '<p>No test results available</p>'}
        </div>
        
        <div class="footer">
            <p>🐝 Wisbee Automated Performance Testing</p>
        </div>
    </div>
</body>
</html>
  `;
}

if (require.main === module) {
  generatePerformanceReport();
}

module.exports = generatePerformanceReport;