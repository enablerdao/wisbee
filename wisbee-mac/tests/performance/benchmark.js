// ⚡ Wisbee Performance Benchmark Tests
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class WisbeePerformanceBenchmark {
  constructor() {
    this.results = {
      timestamp: new Date().toISOString(),
      tests: [],
      summary: {}
    };
  }

  async runAllBenchmarks() {
    console.log('🚀 Starting Wisbee Performance Benchmarks...\n');

    try {
      await this.testStartupTime();
      await this.testModelLoadTime();
      await this.testResponseTime();
      await this.testMemoryUsage();
      await this.testConcurrentUsers();
      
      this.generateSummary();
      this.saveResults();
      this.printResults();
      
    } catch (error) {
      console.error('❌ Benchmark failed:', error);
      process.exit(1);
    }
  }

  async testStartupTime() {
    console.log('📱 Testing app startup time...');
    
    const iterations = 5;
    const times = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = Date.now();
      
      try {
        // Kill any existing processes
        execSync('pkill -f "electron.*wisbee" || true', { stdio: 'ignore' });
        execSync('lsof -ti:8899 | xargs kill -9 || true', { stdio: 'ignore' });
        
        // Start app and measure time to ready
        const child = execSync('timeout 30 npm start &', { 
          stdio: 'ignore',
          timeout: 30000 
        });
        
        // Wait for server to be ready
        await this.waitForServer('http://localhost:8899', 30000);
        
        const duration = Date.now() - start;
        times.push(duration);
        
        console.log(`  Attempt ${i + 1}: ${duration}ms`);
        
        // Clean up
        execSync('pkill -f "electron.*wisbee" || true', { stdio: 'ignore' });
        
      } catch (error) {
        console.warn(`  Attempt ${i + 1}: Failed - ${error.message}`);
        times.push(30000); // Max timeout
      }
      
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
    
    const avgTime = times.reduce((a, b) => a + b, 0) / times.length;
    const minTime = Math.min(...times);
    const maxTime = Math.max(...times);
    
    this.results.tests.push({
      name: 'App Startup Time',
      metric: 'milliseconds',
      average: avgTime,
      min: minTime,
      max: maxTime,
      raw: times,
      pass: avgTime < 10000 // Should start within 10 seconds
    });
    
    console.log(`✅ Average startup time: ${avgTime.toFixed(0)}ms\n`);
  }

  async testModelLoadTime() {
    console.log('🤖 Testing model load time...');
    
    const models = ['smollm2:135m', 'qwen2.5:0.5b'];
    const modelResults = {};
    
    for (const model of models) {
      console.log(`  Testing ${model}...`);
      
      try {
        // Ensure model is available
        execSync(`ollama pull ${model}`, { stdio: 'ignore', timeout: 60000 });
        
        const iterations = 3;
        const times = [];
        
        for (let i = 0; i < iterations; i++) {
          const start = Date.now();
          
          // Make a simple request to load the model
          const response = await fetch('http://localhost:8899/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              model: model,
              messages: [{ role: 'user', content: 'Hello' }],
              stream: false
            })
          });
          
          if (response.ok) {
            const duration = Date.now() - start;
            times.push(duration);
            console.log(`    Load ${i + 1}: ${duration}ms`);
          } else {
            times.push(30000);
          }
          
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
        
        const avgTime = times.reduce((a, b) => a + b, 0) / times.length;
        modelResults[model] = avgTime;
        
      } catch (error) {
        console.warn(`    ${model}: Failed - ${error.message}`);
        modelResults[model] = 30000;
      }
    }
    
    const avgModelLoad = Object.values(modelResults).reduce((a, b) => a + b, 0) / Object.values(modelResults).length;
    
    this.results.tests.push({
      name: 'Model Load Time',
      metric: 'milliseconds',
      average: avgModelLoad,
      details: modelResults,
      pass: avgModelLoad < 5000 // Should load within 5 seconds
    });
    
    console.log(`✅ Average model load time: ${avgModelLoad.toFixed(0)}ms\n`);
  }

  async testResponseTime() {
    console.log('⚡ Testing response time...');
    
    const testCases = [
      { prompt: 'Hello', expected_tokens: 20 },
      { prompt: 'Explain quantum computing in one sentence', expected_tokens: 50 },
      { prompt: 'Write a simple Python function', expected_tokens: 100 }
    ];
    
    const results = [];
    
    for (const testCase of testCases) {
      console.log(`  Testing: "${testCase.prompt}"...`);
      
      try {
        const start = Date.now();
        
        const response = await fetch('http://localhost:8899/api/chat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            model: 'smollm2:135m',
            messages: [{ role: 'user', content: testCase.prompt }],
            stream: false
          })
        });
        
        if (response.ok) {
          const data = await response.json();
          const duration = Date.now() - start;
          const tokensPerSecond = testCase.expected_tokens / (duration / 1000);
          
          results.push({
            prompt: testCase.prompt,
            duration: duration,
            tokensPerSecond: tokensPerSecond
          });
          
          console.log(`    Response time: ${duration}ms (~${tokensPerSecond.toFixed(1)} tok/s)`);
        } else {
          results.push({ prompt: testCase.prompt, duration: 30000, tokensPerSecond: 0 });
        }
        
      } catch (error) {
        console.warn(`    Failed: ${error.message}`);
        results.push({ prompt: testCase.prompt, duration: 30000, tokensPerSecond: 0 });
      }
      
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    const avgResponseTime = results.reduce((a, b) => a + b.duration, 0) / results.length;
    const avgTokensPerSecond = results.reduce((a, b) => a + b.tokensPerSecond, 0) / results.length;
    
    this.results.tests.push({
      name: 'Response Time',
      metric: 'milliseconds',
      average: avgResponseTime,
      tokensPerSecond: avgTokensPerSecond,
      details: results,
      pass: avgResponseTime < 10000 && avgTokensPerSecond > 10
    });
    
    console.log(`✅ Average response time: ${avgResponseTime.toFixed(0)}ms (${avgTokensPerSecond.toFixed(1)} tok/s)\n`);
  }

  async testMemoryUsage() {
    console.log('💾 Testing memory usage...');
    
    try {
      // Get process info
      const processes = execSync('ps aux | grep -E "(electron|ollama)" | grep -v grep', { 
        encoding: 'utf-8' 
      }).split('\n').filter(line => line.trim());
      
      let totalMemory = 0;
      const processDetails = [];
      
      processes.forEach(line => {
        const parts = line.split(/\s+/);
        if (parts.length >= 6) {
          const memory = parseFloat(parts[5]) / 1024; // Convert to MB
          totalMemory += memory;
          processDetails.push({
            process: parts[10] || 'unknown',
            memory: memory
          });
        }
      });
      
      this.results.tests.push({
        name: 'Memory Usage',
        metric: 'MB',
        total: totalMemory,
        details: processDetails,
        pass: totalMemory < 1024 // Should use less than 1GB
      });
      
      console.log(`✅ Total memory usage: ${totalMemory.toFixed(0)}MB\n`);
      
    } catch (error) {
      console.warn(`  Memory test failed: ${error.message}\n`);
      this.results.tests.push({
        name: 'Memory Usage',
        metric: 'MB',
        total: 0,
        pass: false
      });
    }
  }

  async testConcurrentUsers() {
    console.log('👥 Testing concurrent users...');
    
    const concurrentRequests = 5;
    const promises = [];
    
    const start = Date.now();
    
    for (let i = 0; i < concurrentRequests; i++) {
      const promise = fetch('http://localhost:8899/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: 'smollm2:135m',
          messages: [{ role: 'user', content: `Test message ${i + 1}` }],
          stream: false
        })
      }).then(response => ({
        success: response.ok,
        status: response.status
      })).catch(error => ({
        success: false,
        error: error.message
      }));
      
      promises.push(promise);
    }
    
    const results = await Promise.all(promises);
    const duration = Date.now() - start;
    const successCount = results.filter(r => r.success).length;
    
    this.results.tests.push({
      name: 'Concurrent Users',
      metric: 'requests',
      total: concurrentRequests,
      successful: successCount,
      duration: duration,
      pass: successCount >= concurrentRequests * 0.8 // 80% success rate
    });
    
    console.log(`✅ Concurrent test: ${successCount}/${concurrentRequests} successful in ${duration}ms\n`);
  }

  async waitForServer(url, timeout = 30000) {
    const start = Date.now();
    
    while (Date.now() - start < timeout) {
      try {
        const response = await fetch(url);
        if (response.ok) return true;
      } catch (error) {
        // Continue waiting
      }
      await new Promise(resolve => setTimeout(resolve, 500));
    }
    
    throw new Error('Server did not start within timeout');
  }

  generateSummary() {
    const passedTests = this.results.tests.filter(t => t.pass).length;
    const totalTests = this.results.tests.length;
    
    this.results.summary = {
      totalTests,
      passedTests,
      failedTests: totalTests - passedTests,
      passRate: (passedTests / totalTests) * 100,
      overallPass: passedTests === totalTests
    };
  }

  saveResults() {
    const outputDir = path.join(__dirname, '../../performance-report');
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    
    const filename = path.join(outputDir, `benchmark-${Date.now()}.json`);
    fs.writeFileSync(filename, JSON.stringify(this.results, null, 2));
    
    console.log(`📊 Results saved to: ${filename}`);
  }

  printResults() {
    console.log('\n' + '='.repeat(50));
    console.log('🏆 WISBEE PERFORMANCE BENCHMARK RESULTS');
    console.log('='.repeat(50));
    
    this.results.tests.forEach(test => {
      const status = test.pass ? '✅' : '❌';
      console.log(`${status} ${test.name}: ${test.average?.toFixed(0) || test.total} ${test.metric}`);
    });
    
    console.log('\n' + '-'.repeat(30));
    console.log(`📊 Summary: ${this.results.summary.passedTests}/${this.results.summary.totalTests} tests passed (${this.results.summary.passRate.toFixed(1)}%)`);
    
    if (this.results.summary.overallPass) {
      console.log('🎉 All performance benchmarks PASSED!');
    } else {
      console.log('⚠️  Some performance benchmarks FAILED!');
      process.exit(1);
    }
  }
}

// Run benchmarks if called directly
if (require.main === module) {
  const benchmark = new WisbeePerformanceBenchmark();
  benchmark.runAllBenchmarks().catch(console.error);
}

module.exports = WisbeePerformanceBenchmark;