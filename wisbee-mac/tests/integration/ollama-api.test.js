const axios = require('axios');

describe('🐝 Ollama API Integration Tests', () => {
  const OLLAMA_BASE_URL = 'http://localhost:11434';
  const APP_API_URL = 'http://localhost:8899/api';

  beforeAll(async () => {
    // Check if Ollama is running
    try {
      await axios.get(`${OLLAMA_BASE_URL}/api/version`);
    } catch (error) {
      console.warn('⚠️ Ollama not running, some tests may fail');
    }

    // Ensure test models are available
    try {
      await axios.post(`${OLLAMA_BASE_URL}/api/pull`, {
        name: 'smollm2:135m'
      });
      console.log('✅ Test model available');
    } catch (error) {
      console.warn('⚠️ Could not pull test model');
    }
  }, 60000);

  describe('Direct Ollama API Tests', () => {
    test('should connect to Ollama server', async () => {
      const response = await axios.get(`${OLLAMA_BASE_URL}/api/version`);
      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('version');
    });

    test('should list available models', async () => {
      const response = await axios.get(`${OLLAMA_BASE_URL}/api/tags`);
      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('models');
      expect(Array.isArray(response.data.models)).toBe(true);
    });

    test('should generate a simple response', async () => {
      const response = await axios.post(`${OLLAMA_BASE_URL}/api/generate`, {
        model: 'smollm2:135m',
        prompt: 'Hello',
        stream: false
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('response');
      expect(typeof response.data.response).toBe('string');
    }, 30000);

    test('should handle chat format', async () => {
      const response = await axios.post(`${OLLAMA_BASE_URL}/api/chat`, {
        model: 'smollm2:135m',
        messages: [
          {
            role: 'user',
            content: 'Say hello'
          }
        ],
        stream: false
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('message');
      expect(response.data.message).toHaveProperty('content');
    }, 30000);
  });

  describe('Wisbee API Proxy Tests', () => {
    test('should proxy chat requests to Ollama', async () => {
      const response = await axios.post(`${APP_API_URL}/chat`, {
        model: 'smollm2:135m',
        messages: [
          {
            role: 'user',
            content: 'Test message'
          }
        ]
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('message');
    }, 30000);

    test('should handle streaming responses', async () => {
      const response = await axios.post(`${APP_API_URL}/chat`, {
        model: 'smollm2:135m',
        messages: [
          {
            role: 'user',
            content: 'Count to 3'
          }
        ],
        stream: true
      }, {
        responseType: 'stream'
      });

      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toContain('text/plain');
    }, 30000);

    test('should handle model list requests', async () => {
      const response = await axios.get(`${APP_API_URL}/tags`);
      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('models');
    });

    test('should handle invalid model requests', async () => {
      try {
        await axios.post(`${APP_API_URL}/chat`, {
          model: 'nonexistent-model',
          messages: [
            {
              role: 'user',
              content: 'Test'
            }
          ]
        });
      } catch (error) {
        expect(error.response.status).toBeGreaterThanOrEqual(400);
      }
    });
  });

  describe('Error Handling Tests', () => {
    test('should handle Ollama server down', async () => {
      // Mock server down scenario
      const invalidUrl = 'http://localhost:99999/api/chat';
      
      try {
        await axios.post(invalidUrl, {
          model: 'test',
          messages: [{ role: 'user', content: 'test' }]
        }, { timeout: 1000 });
      } catch (error) {
        expect(error.code).toBe('ECONNREFUSED');
      }
    });

    test('should handle malformed requests', async () => {
      try {
        await axios.post(`${APP_API_URL}/chat`, {
          // Missing required fields
          invalid: 'data'
        });
      } catch (error) {
        expect(error.response.status).toBeGreaterThanOrEqual(400);
      }
    });

    test('should handle timeout scenarios', async () => {
      try {
        await axios.post(`${APP_API_URL}/chat`, {
          model: 'smollm2:135m',
          messages: [
            {
              role: 'user',
              content: 'Write a very long story about artificial intelligence'
            }
          ]
        }, { timeout: 100 }); // Very short timeout
      } catch (error) {
        expect(error.code).toBe('ECONNABORTED');
      }
    });
  });

  describe('Performance Tests', () => {
    test('should respond within reasonable time', async () => {
      const startTime = Date.now();
      
      await axios.post(`${APP_API_URL}/chat`, {
        model: 'smollm2:135m',
        messages: [
          {
            role: 'user',
            content: 'Hi'
          }
        ]
      });

      const responseTime = Date.now() - startTime;
      expect(responseTime).toBeLessThan(10000); // Should respond within 10 seconds
    }, 15000);

    test('should handle concurrent requests', async () => {
      const promises = [];
      
      for (let i = 0; i < 3; i++) {
        promises.push(
          axios.post(`${APP_API_URL}/chat`, {
            model: 'smollm2:135m',
            messages: [
              {
                role: 'user',
                content: `Concurrent request ${i + 1}`
              }
            ]
          })
        );
      }

      const responses = await Promise.all(promises);
      
      responses.forEach(response => {
        expect(response.status).toBe(200);
        expect(response.data).toHaveProperty('message');
      });
    }, 45000);
  });

  describe('Model Management Tests', () => {
    test('should validate model availability before chat', async () => {
      // First check if model exists
      const modelsResponse = await axios.get(`${APP_API_URL}/tags`);
      const availableModels = modelsResponse.data.models.map(m => m.name);
      
      if (availableModels.length > 0) {
        const testModel = availableModels[0];
        
        const chatResponse = await axios.post(`${APP_API_URL}/chat`, {
          model: testModel,
          messages: [
            {
              role: 'user',
              content: 'Test with available model'
            }
          ]
        });

        expect(chatResponse.status).toBe(200);
      }
    }, 30000);

    test('should handle model switching gracefully', async () => {
      const modelsResponse = await axios.get(`${APP_API_URL}/tags`);
      const availableModels = modelsResponse.data.models;
      
      if (availableModels.length >= 2) {
        // Test with first model
        const response1 = await axios.post(`${APP_API_URL}/chat`, {
          model: availableModels[0].name,
          messages: [{ role: 'user', content: 'Test 1' }]
        });

        // Test with second model
        const response2 = await axios.post(`${APP_API_URL}/chat`, {
          model: availableModels[1].name,
          messages: [{ role: 'user', content: 'Test 2' }]
        });

        expect(response1.status).toBe(200);
        expect(response2.status).toBe(200);
      }
    }, 60000);
  });
});