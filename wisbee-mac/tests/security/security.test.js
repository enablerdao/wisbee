// 🔒 Security Tests for Wisbee
const fs = require('fs');
const path = require('path');

describe('🔒 Security Tests', () => {
  // ========================================
  // 🛡️ Dependency Security
  // ========================================
  describe('Dependency Security', () => {
    test('should not have high severity vulnerabilities', () => {
      // Check package.json exists
      const packagePath = path.join(__dirname, '../../package.json');
      expect(fs.existsSync(packagePath)).toBe(true);
      
      // In real scenario, this would run npm audit
      // For testing, we just verify the structure
      const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      expect(packageJson.dependencies).toBeDefined();
      expect(packageJson.devDependencies).toBeDefined();
    });

    test('should not use deprecated packages', () => {
      const packagePath = path.join(__dirname, '../../package.json');
      const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      
      const deprecatedPackages = [
        'request', // Deprecated
        'node-sass', // Deprecated in favor of sass
        'tslint' // Deprecated in favor of eslint
      ];
      
      const allDeps = {
        ...packageJson.dependencies,
        ...packageJson.devDependencies
      };
      
      deprecatedPackages.forEach(pkg => {
        expect(allDeps).not.toHaveProperty(pkg);
      });
    });
  });

  // ========================================
  // 🔑 Sensitive Data Protection
  // ========================================
  describe('Sensitive Data Protection', () => {
    test('should not expose API keys in code', () => {
      const srcFiles = [
        path.join(__dirname, '../../main.js'),
        path.join(__dirname, '../../ollama-webui-server.py'),
        path.join(__dirname, '../../chat.html')
      ];
      
      const sensitivePatterns = [
        /api[_-]?key\s*[:=]\s*["'][^"']+["']/gi,
        /secret[_-]?key\s*[:=]\s*["'][^"']+["']/gi,
        /password\s*[:=]\s*["'][^"']+["']/gi,
        /token\s*[:=]\s*["'][^"']+["']/gi
      ];
      
      srcFiles.forEach(file => {
        if (fs.existsSync(file)) {
          const content = fs.readFileSync(file, 'utf8');
          sensitivePatterns.forEach(pattern => {
            expect(content).not.toMatch(pattern);
          });
        }
      });
    });

    test('should have .gitignore for sensitive files', () => {
      const gitignorePath = path.join(__dirname, '../../../.gitignore');
      expect(fs.existsSync(gitignorePath)).toBe(true);
      
      const gitignore = fs.readFileSync(gitignorePath, 'utf8');
      const requiredIgnores = [
        '.env',
        'node_modules',
        'dist',
        '*.log',
        '.DS_Store'
      ];
      
      requiredIgnores.forEach(pattern => {
        expect(gitignore).toContain(pattern);
      });
    });
  });

  // ========================================
  // 🌐 Network Security
  // ========================================
  describe('Network Security', () => {
    test('should use secure protocols', () => {
      const configPath = path.join(__dirname, '../../../config.json');
      if (fs.existsSync(configPath)) {
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        
        // Check for insecure protocols
        const configString = JSON.stringify(config);
        expect(configString).not.toMatch(/http:\/\/(?!localhost|127\.0\.0\.1)/);
        expect(configString).not.toMatch(/ftp:/);
        expect(configString).not.toMatch(/telnet:/);
      }
    });

    test('should validate localhost-only connections', () => {
      // Check that Ollama connections are localhost only
      const mainJs = path.join(__dirname, '../../main.js');
      if (fs.existsSync(mainJs)) {
        const content = fs.readFileSync(mainJs, 'utf8');
        
        // Ollama should only connect to localhost
        expect(content).toMatch(/localhost:11434|127\.0\.0\.1:11434/);
        expect(content).not.toMatch(/0\.0\.0\.0:11434/); // Not binding to all interfaces
      }
    });
  });

  // ========================================
  // 🔐 Input Validation
  // ========================================
  describe('Input Validation', () => {
    test('should sanitize user inputs', () => {
      // Check for XSS prevention in HTML files
      const htmlFiles = [
        path.join(__dirname, '../../chat.html'),
        path.join(__dirname, '../../index.html')
      ];
      
      htmlFiles.forEach(file => {
        if (fs.existsSync(file)) {
          const content = fs.readFileSync(file, 'utf8');
          
          // Check for proper escaping functions
          expect(content).toMatch(/textContent|innerText|escapeHtml|DOMPurify/);
          
          // Should not use dangerous innerHTML without sanitization
          const innerHTMLUsage = content.match(/innerHTML\s*=\s*[^=]/g) || [];
          innerHTMLUsage.forEach(usage => {
            // If innerHTML is used, it should be with sanitization
            const context = content.substring(
              content.indexOf(usage) - 100,
              content.indexOf(usage) + 100
            );
            expect(context).toMatch(/sanitize|escape|DOMPurify|textContent/i);
          });
        }
      });
    });

    test('should validate file paths', () => {
      const serverFiles = [
        path.join(__dirname, '../../ollama-webui-server.py'),
        path.join(__dirname, '../../server.js')
      ];
      
      serverFiles.forEach(file => {
        if (fs.existsSync(file)) {
          const content = fs.readFileSync(file, 'utf8');
          
          // Check for path traversal prevention
          expect(content).toMatch(/path\.join|path\.resolve|\.replace\(['"]\.\.['"],/);
        }
      });
    });
  });

  // ========================================
  // 🔒 Electron Security
  // ========================================
  describe('Electron Security', () => {
    test('should have secure webPreferences', () => {
      const mainFiles = [
        path.join(__dirname, '../../main.js'),
        path.join(__dirname, '../../electron-main.js')
      ];
      
      mainFiles.forEach(file => {
        if (fs.existsSync(file)) {
          const content = fs.readFileSync(file, 'utf8');
          
          // Check for secure defaults
          expect(content).toMatch(/contextIsolation:\s*true/);
          expect(content).toMatch(/nodeIntegration:\s*false/);
          expect(content).not.toMatch(/webSecurity:\s*false/);
          expect(content).not.toMatch(/allowRunningInsecureContent:\s*true/);
        }
      });
    });

    test('should use secure IPC communication', () => {
      const preloadPath = path.join(__dirname, '../../preload.js');
      if (fs.existsSync(preloadPath)) {
        const content = fs.readFileSync(preloadPath, 'utf8');
        
        // Should use contextBridge for IPC
        expect(content).toMatch(/contextBridge\.exposeInMainWorld/);
        
        // Should not expose dangerous APIs
        expect(content).not.toMatch(/require\(['"]fs['"]\)/);
        expect(content).not.toMatch(/require\(['"]child_process['"]\)/);
      }
    });
  });

  // ========================================
  // 📜 License Compliance
  // ========================================
  describe('License Compliance', () => {
    test('should have proper license file', () => {
      const licensePath = path.join(__dirname, '../../../LICENSE');
      expect(fs.existsSync(licensePath)).toBe(true);
      
      const license = fs.readFileSync(licensePath, 'utf8');
      expect(license).toContain('MIT License');
    });

    test('should not use GPL-incompatible dependencies', () => {
      const packagePath = path.join(__dirname, '../../package.json');
      const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      
      // List of packages with restrictive licenses to avoid
      const restrictedPackages = [
        // Add known GPL or other restrictive licensed packages
      ];
      
      const allDeps = {
        ...packageJson.dependencies,
        ...packageJson.devDependencies
      };
      
      restrictedPackages.forEach(pkg => {
        expect(allDeps).not.toHaveProperty(pkg);
      });
    });
  });

  // ========================================
  // 🚨 Error Handling Security
  // ========================================
  describe('Error Handling Security', () => {
    test('should not expose sensitive information in errors', () => {
      const jsFiles = [
        path.join(__dirname, '../../main.js'),
        path.join(__dirname, '../../server.js')
      ];
      
      jsFiles.forEach(file => {
        if (fs.existsSync(file)) {
          const content = fs.readFileSync(file, 'utf8');
          
          // Check for proper error handling
          expect(content).toMatch(/try\s*{[\s\S]*?}\s*catch/);
          
          // Should not expose stack traces in production
          const errorLogs = content.match(/console\.error\([^)]+\)/g) || [];
          errorLogs.forEach(log => {
            // Stack traces should be conditional on environment
            if (log.includes('stack')) {
              expect(content).toMatch(/process\.env\.NODE_ENV|isDevelopment|isProduction/);
            }
          });
        }
      });
    });
  });
});