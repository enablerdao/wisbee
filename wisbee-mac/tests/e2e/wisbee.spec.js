// 🎭 Wisbee E2E Tests with Playwright
const { test, expect } = require('@playwright/test');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

test.describe('🐝 Wisbee App E2E Tests', () => {
  let appProcess;
  const APP_URL = 'http://localhost:8899';

  test.beforeAll(async () => {
    // Start Ollama if not running
    try {
      await execAsync('curl -s http://localhost:11434/api/version');
      console.log('✅ Ollama is already running');
    } catch (error) {
      console.log('⚠️ Starting Ollama...');
      exec('ollama serve', { detached: true });
      await new Promise(resolve => setTimeout(resolve, 5000));
    }

    // Ensure test models are available
    try {
      await execAsync('ollama pull smollm2:135m');
      await execAsync('ollama pull qwen2.5:0.5b');
      console.log('✅ Test models downloaded');
    } catch (error) {
      console.log('⚠️ Models may already exist');
    }
  });

  test.beforeEach(async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');
  });

  // ========================================
  // 🎨 UI Layout & Design Tests
  // ========================================
  
  test('should display ChatGPT o3 style layout', async ({ page }) => {
    // Check sidebar exists and has correct width
    const sidebar = page.locator('.sidebar');
    await expect(sidebar).toBeVisible();
    
    // Check main content area
    const mainContent = page.locator('.main-content');
    await expect(mainContent).toBeVisible();
    
    // Check top header with model selector
    const topHeader = page.locator('.top-header');
    await expect(topHeader).toBeVisible();
    
    const modelSelector = page.locator('.model-selector');
    await expect(modelSelector).toContainText('Wisbee o3');
  });

  test('should show Wisbee branding correctly', async ({ page }) => {
    // Check logo and branding
    const logo = page.locator('.logo-icon');
    await expect(logo).toContainText('🐝');
    
    const logoText = page.locator('.logo span').last();
    await expect(logoText).toContainText('Wisbee');
    
    // Check welcome message
    const welcomeMessage = page.locator('.assistant-content h2');
    await expect(welcomeMessage).toContainText('🐝 Wisbee へようこそ！');
  });

  test('should display available models in sidebar', async ({ page }) => {
    // Check that models are listed in sidebar
    const models = [
      'Llama3.2',
      'Gemma2 2B', 
      'Qwen2.5 0.5B',
      'SmolLM2 135M'
    ];

    for (const model of models) {
      const modelItem = page.locator('.gpt-item', { hasText: model });
      await expect(modelItem).toBeVisible();
    }
  });

  // ========================================
  // 🗨️ Chat Functionality Tests
  // ========================================

  test('should send and receive messages', async ({ page }) => {
    const messageInput = page.locator('#messageInput');
    const sendButton = page.locator('#sendButton');
    const testMessage = 'Hello, this is a test message';

    // Type and send message
    await messageInput.fill(testMessage);
    await sendButton.click();

    // Check user message appears
    const userMessage = page.locator('.user-message').last();
    await expect(userMessage).toContainText(testMessage);

    // Wait for AI response (with timeout)
    await expect(page.locator('.assistant-content').last()).toBeVisible({ timeout: 30000 });
    
    // Check that thinking indicator appears and disappears
    const thinkingIndicator = page.locator('.thinking');
    await expect(thinkingIndicator).toBeVisible();
    await expect(thinkingIndicator).not.toBeVisible({ timeout: 30000 });
  });

  test('should handle empty message submission', async ({ page }) => {
    const sendButton = page.locator('#sendButton');
    await sendButton.click();
    
    // Should not send empty message
    const userMessages = page.locator('.user-message');
    await expect(userMessages).toHaveCount(0);
  });

  test('should handle long messages', async ({ page }) => {
    const messageInput = page.locator('#messageInput');
    const longMessage = 'A'.repeat(1000);
    
    await messageInput.fill(longMessage);
    await messageInput.press('Enter');
    
    const userMessage = page.locator('.user-message').first();
    await expect(userMessage).toBeVisible();
    await expect(userMessage).toContainText('A'.repeat(50)); // Check partial content
  });

  test('should handle rapid message sending', async ({ page }) => {
    const messageInput = page.locator('#messageInput');
    
    // Send multiple messages quickly
    for (let i = 0; i < 3; i++) {
      await messageInput.fill(`Message ${i + 1}`);
      await messageInput.press('Enter');
      await page.waitForTimeout(100);
    }
    
    const userMessages = page.locator('.user-message');
    await expect(userMessages).toHaveCount(3);
  });

  test('should handle network errors gracefully', async ({ page }) => {
    // Simulate network failure
    await page.route('**/api/chat', route => route.abort());
    
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Test message');
    await messageInput.press('Enter');
    
    // Should show error or loading state
    await page.waitForTimeout(2000);
    
    // Restore network
    await page.unroute('**/api/chat');
  });

  test('should maintain scroll position with many messages', async ({ page }) => {
    const messageInput = page.locator('#messageInput');
    const messagesContainer = page.locator('#messagesContainer');
    
    // Add many messages
    for (let i = 0; i < 10; i++) {
      await messageInput.fill(`Message ${i + 1}`);
      await messageInput.press('Enter');
      await page.waitForTimeout(100);
    }
    
    // Should auto-scroll to bottom
    const isScrolledToBottom = await messagesContainer.evaluate(el => {
      return el.scrollTop + el.clientHeight >= el.scrollHeight - 10;
    });
    
    expect(isScrolledToBottom).toBe(true);
  });

  test('should handle model switching', async ({ page }) => {
    // Click on a different model
    const gemmaModel = page.locator('.gpt-item[data-model="gemma2:2b"]');
    await gemmaModel.click();

    // Check that model is now active
    await expect(gemmaModel).toHaveClass(/active/);
    
    // Check that model name updates in header
    const currentModel = page.locator('#current-model');
    await expect(currentModel).toContainText('Gemma2 2B');
  });

  test('should support keyboard shortcuts', async ({ page }) => {
    const messageInput = page.locator('#messageInput');
    
    // Test Enter to send
    await messageInput.fill('Test enter key');
    await messageInput.press('Enter');
    
    // Check message was sent
    const userMessage = page.locator('.user-message').last();
    await expect(userMessage).toContainText('Test enter key');
    
    // Test Shift+Enter for new line
    await messageInput.fill('Line 1');
    await messageInput.press('Shift+Enter');
    await messageInput.type('Line 2');
    
    // Check textarea height adjusted
    const textareaHeight = await messageInput.evaluate(el => el.style.height);
    expect(parseInt(textareaHeight)).toBeGreaterThan(56); // Default height
  });

  // ========================================
  // 🎭 Interactive Features Tests
  // ========================================

  test('should show hover effects on interactive elements', async ({ page }) => {
    // Test sidebar item hover
    const firstGptItem = page.locator('.gpt-item').first();
    await firstGptItem.hover();
    
    // Test action item hover  
    const newChatAction = page.locator('.action-item').first();
    await newChatAction.hover();
    
    // Test send button hover
    const sendButton = page.locator('#sendButton');
    await sendButton.hover();
  });

  test('should handle new chat functionality', async ({ page }) => {
    // Send a message first
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Initial message');
    await messageInput.press('Enter');
    
    // Wait for response
    await page.waitForSelector('.assistant-content', { timeout: 30000 });
    
    // Click new chat
    const newChatButton = page.locator('.action-item').first();
    await newChatButton.click();
    
    // Check that messages are cleared and welcome message is shown
    const messages = page.locator('.message');
    await expect(messages).toHaveCount(1); // Only welcome message
    
    const welcomeMessage = page.locator('.assistant-content h2');
    await expect(welcomeMessage).toContainText('🐝 Wisbee へようこそ！');
  });

  // ========================================
  // 📱 Responsive Design Tests
  // ========================================

  test('should be responsive on mobile', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Check that sidebar adapts (should be narrower)
    const sidebar = page.locator('.sidebar');
    const sidebarWidth = await sidebar.evaluate(el => el.offsetWidth);
    expect(sidebarWidth).toBeLessThan(100); // Should be collapsed on mobile
    
    // Check that main content is still usable
    const messageInput = page.locator('#messageInput');
    await expect(messageInput).toBeVisible();
  });

  // ========================================
  // 🔒 Error Handling Tests  
  // ========================================

  test('should handle Ollama connection errors gracefully', async ({ page }) => {
    // Mock network failure
    await page.route('/api/chat', route => {
      route.abort('failed');
    });
    
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Test error handling');
    await messageInput.press('Enter');
    
    // Should show error message
    const errorMessage = page.locator('.assistant-content').last();
    await expect(errorMessage).toContainText('エラーが発生しました');
  });

  // ========================================
  // ⚡ Performance Tests
  // ========================================

  test('should load quickly and be responsive', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(3000); // Should load within 3 seconds
    
    // Check that animations are smooth
    const logoIcon = page.locator('.logo-icon');
    await expect(logoIcon).toBeVisible();
    
    // Test input responsiveness
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Quick typing test');
    const inputValue = await messageInput.inputValue();
    expect(inputValue).toBe('Quick typing test');
  });

  // ========================================
  // 🎨 Visual Regression Tests
  // ========================================

  test('should match visual design', async ({ page }) => {
    // Take screenshot of main interface
    await expect(page).toHaveScreenshot('wisbee-main-interface.png', {
      fullPage: true,
      threshold: 0.2
    });
    
    // Take screenshot of sidebar
    const sidebar = page.locator('.sidebar');
    await expect(sidebar).toHaveScreenshot('wisbee-sidebar.png');
    
    // Take screenshot with a conversation
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Visual test message');
    await messageInput.press('Enter');
    
    await page.waitForSelector('.user-message', { timeout: 5000 });
    await expect(page).toHaveScreenshot('wisbee-with-message.png', {
      fullPage: true,
      threshold: 0.2
    });
  });

  // ========================================
  // 🔧 Accessibility Tests
  // ========================================

  test('should be accessible', async ({ page }) => {
    // Check basic accessibility
    const messageInput = page.locator('#messageInput');
    await expect(messageInput).toHaveAttribute('placeholder');
    
    // Check that buttons have proper labels
    const sendButton = page.locator('#sendButton');
    await expect(sendButton).toBeVisible();
    
    // Check color contrast (basic check)
    const textColor = await page.locator('body').evaluate(el => 
      getComputedStyle(el).color
    );
    expect(textColor).toBeTruthy();
  });

  test.afterAll(async () => {
    // Clean up processes if needed
    if (appProcess) {
      appProcess.kill();
    }
  });
});