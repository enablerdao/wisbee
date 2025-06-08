// 🤖 Automated Checks for Wisbee
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

describe('🤖 Automated Quality Checks', () => {
  // ========================================
  // 📦 Package Health
  // ========================================
  describe('Package Health', () => {
    test('should have valid package.json', () => {
      const packagePath = path.join(__dirname, '../../package.json');
      const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      
      // Required fields
      expect(packageJson.name).toBeDefined();
      expect(packageJson.version).toMatch(/^\d+\.\d+\.\d+$/);
      expect(packageJson.main).toBeDefined();
      expect(packageJson.scripts).toBeDefined();
      expect(packageJson.scripts.test).toBeDefined();
      expect(packageJson.scripts.start).toBeDefined();
      expect(packageJson.license).toBeDefined();
    });

    test('should have all required scripts', () => {
      const packagePath = path.join(__dirname, '../../package.json');
      const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      
      const requiredScripts = [
        'start',
        'test',
        'test:unit',
        'test:e2e',
        'lint',
        'build'
      ];
      
      requiredScripts.forEach(script => {
        expect(packageJson.scripts[script]).toBeDefined();
      });
    });

    test('should have consistent dependencies', () => {
      const packagePath = path.join(__dirname, '../../package.json');
      const lockPath = path.join(__dirname, '../../package-lock.json');
      
      expect(fs.existsSync(packagePath)).toBe(true);
      expect(fs.existsSync(lockPath)).toBe(true);
      
      // Check lock file is not outdated
      const packageMtime = fs.statSync(packagePath).mtime;
      const lockMtime = fs.statSync(lockPath).mtime;
      
      // Lock file should be newer or same age as package.json
      expect(lockMtime >= packageMtime).toBe(true);
    });
  });

  // ========================================
  // 📁 Project Structure
  // ========================================
  describe('Project Structure', () => {
    test('should have required directories', () => {
      const requiredDirs = [
        'tests',
        'tests/unit',
        'tests/e2e',
        'assets',
        '.github/workflows'
      ];
      
      requiredDirs.forEach(dir => {
        const dirPath = path.join(__dirname, '../../', dir);
        expect(fs.existsSync(dirPath)).toBe(true);
      });
    });

    test('should have required configuration files', () => {
      const requiredFiles = [
        'package.json',
        'package-lock.json',
        '.gitignore',
        'README.md',
        'jest.config.js',
        'playwright.config.js',
        '.eslintrc.js',
        '.prettierrc'
      ];
      
      requiredFiles.forEach(file => {
        const filePath = path.join(__dirname, '../../', file);
        expect(fs.existsSync(filePath)).toBe(true);
      });
    });
  });

  // ========================================
  // 📊 Code Metrics
  // ========================================
  describe('Code Metrics', () => {
    test('should not have excessively large files', () => {
      const maxFileSize = 500; // Max lines per file
      const srcFiles = [
        'main.js',
        'chat.html',
        'ollama-webui-server.py'
      ];
      
      srcFiles.forEach(file => {
        const filePath = path.join(__dirname, '../../', file);
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, 'utf8');
          const lineCount = content.split('\n').length;
          
          expect(lineCount).toBeLessThan(maxFileSize);
        }
      });
    });

    test('should maintain consistent code style', () => {
      const jsFiles = fs.readdirSync(path.join(__dirname, '../../'))
        .filter(f => f.endsWith('.js'))
        .map(f => path.join(__dirname, '../../', f));
      
      jsFiles.forEach(file => {
        const content = fs.readFileSync(file, 'utf8');
        
        // Check for consistent indentation (2 spaces)
        const lines = content.split('\n');
        lines.forEach((line, index) => {
          if (line.match(/^\s+/)) {
            const leadingSpaces = line.match(/^(\s+)/)[1];
            expect(leadingSpaces.length % 2).toBe(0);
          }
        });
        
        // Check for semicolons
        expect(content).toMatch(/;$/m);
      });
    });
  });

  // ========================================
  // 🌐 Internationalization
  // ========================================
  describe('Internationalization', () => {
    test('should support Japanese characters', () => {
      const htmlFiles = [
        'chat.html',
        'index.html'
      ];
      
      htmlFiles.forEach(file => {
        const filePath = path.join(__dirname, '../../', file);
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, 'utf8');
          
          // Check for UTF-8 declaration
          expect(content).toMatch(/<meta[^>]+charset=["']utf-8["']/i);
          
          // Check for Japanese text
          expect(content).toMatch(/[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]/);
        }
      });
    });
  });

  // ========================================
  // 🔄 CI/CD Configuration
  // ========================================
  describe('CI/CD Configuration', () => {
    test('should have valid GitHub Actions workflows', () => {
      const workflowDir = path.join(__dirname, '../../../.github/workflows');
      if (fs.existsSync(workflowDir)) {
        const workflows = fs.readdirSync(workflowDir)
          .filter(f => f.endsWith('.yml') || f.endsWith('.yaml'));
        
        expect(workflows.length).toBeGreaterThan(0);
        
        workflows.forEach(workflow => {
          const content = fs.readFileSync(path.join(workflowDir, workflow), 'utf8');
          
          // Basic YAML structure checks
          expect(content).toMatch(/^name:/m);
          expect(content).toMatch(/^on:/m);
          expect(content).toMatch(/^jobs:/m);
        });
      }
    });
  });

  // ========================================
  // 📝 Documentation
  // ========================================
  describe('Documentation', () => {
    test('should have comprehensive README', () => {
      const readmePath = path.join(__dirname, '../../README.md');
      const readme = fs.readFileSync(readmePath, 'utf8');
      
      // Check for essential sections
      const essentialSections = [
        '# Wisbee',
        '## Installation',
        '## Usage',
        '## Features',
        '## License'
      ];
      
      essentialSections.forEach(section => {
        expect(readme).toMatch(new RegExp(section, 'i'));
      });
      
      // Check minimum length
      expect(readme.length).toBeGreaterThan(1000);
    });

    test('should have inline code documentation', () => {
      const mainJs = path.join(__dirname, '../../main.js');
      if (fs.existsSync(mainJs)) {
        const content = fs.readFileSync(mainJs, 'utf8');
        
        // Check for comments
        expect(content).toMatch(/\/\//);
        expect(content).toMatch(/\/\*[\s\S]*?\*\//);
        
        // Check for function documentation
        const functionCount = (content.match(/function\s+\w+/g) || []).length;
        const commentCount = (content.match(/\/\/|\/\*/g) || []).length;
        
        // Should have at least some comments per function
        expect(commentCount).toBeGreaterThan(functionCount * 0.5);
      }
    });
  });

  // ========================================
  // ⚡ Performance Checks
  // ========================================
  describe('Performance Checks', () => {
    test('should not have synchronous file operations in main process', () => {
      const mainFiles = ['main.js', 'electron-main.js'];
      
      mainFiles.forEach(file => {
        const filePath = path.join(__dirname, '../../', file);
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, 'utf8');
          
          // Check for async file operations
          const syncOps = content.match(/fs\.(readFileSync|writeFileSync|existsSync)/g) || [];
          const asyncOps = content.match(/fs\.(readFile|writeFile|promises)/g) || [];
          
          // Async operations should outnumber sync ones
          expect(asyncOps.length).toBeGreaterThanOrEqual(syncOps.length);
        }
      });
    });

    test('should optimize asset loading', () => {
      const htmlFiles = ['chat.html', 'index.html'];
      
      htmlFiles.forEach(file => {
        const filePath = path.join(__dirname, '../../', file);
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, 'utf8');
          
          // Check for async/defer script loading
          const scripts = content.match(/<script[^>]*>/g) || [];
          scripts.forEach(script => {
            if (!script.includes('inline')) {
              expect(script).toMatch(/async|defer/);
            }
          });
          
          // Check for preloading critical resources
          expect(content).toMatch(/<link[^>]*rel=["']preload["']/);
        }
      });
    });
  });

  // ========================================
  // 🔍 Accessibility Compliance
  // ========================================
  describe('Accessibility Compliance', () => {
    test('should have proper HTML structure', () => {
      const htmlFiles = ['chat.html', 'index.html'];
      
      htmlFiles.forEach(file => {
        const filePath = path.join(__dirname, '../../', file);
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, 'utf8');
          
          // Check for semantic HTML
          expect(content).toMatch(/<main[^>]*>/);
          expect(content).toMatch(/<nav[^>]*>/);
          expect(content).toMatch(/<header[^>]*>|<footer[^>]*>/);
          
          // Check for proper heading hierarchy
          expect(content).toMatch(/<h1[^>]*>/);
          
          // Check for alt text on images
          const images = content.match(/<img[^>]*>/g) || [];
          images.forEach(img => {
            expect(img).toMatch(/alt=["'][^"']*["']/);
          });
        }
      });
    });
  });
});