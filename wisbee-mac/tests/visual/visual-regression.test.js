// 🎨 Visual Regression Tests for Wisbee
const { test, expect } = require('@playwright/test');

test.describe('🐝 Visual Regression Tests', () => {
  const APP_URL = 'http://localhost:8899';

  test.beforeEach(async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');
    
    // Wait for any animations to settle
    await page.waitForTimeout(1000);
  });

  // ========================================
  // 🎨 Main Interface Screenshots
  // ========================================

  test('should match main interface design', async ({ page }) => {
    // Take full page screenshot
    await expect(page).toHaveScreenshot('main-interface.png', {
      fullPage: true,
      threshold: 0.2,
      maxDiffPixels: 1000
    });
  });

  test('should match sidebar design', async ({ page }) => {
    const sidebar = page.locator('.sidebar');
    await expect(sidebar).toHaveScreenshot('sidebar.png', {
      threshold: 0.1
    });
  });

  test('should match chat header design', async ({ page }) => {
    const header = page.locator('.top-header');
    await expect(header).toHaveScreenshot('chat-header.png', {
      threshold: 0.1
    });
  });

  test('should match welcome message design', async ({ page }) => {
    const welcomeMessage = page.locator('.assistant-content').first();
    await expect(welcomeMessage).toHaveScreenshot('welcome-message.png', {
      threshold: 0.1
    });
  });

  // ========================================
  // 💬 Chat Interface Screenshots
  // ========================================

  test('should match message input design', async ({ page }) => {
    const inputContainer = page.locator('.input-container');
    await expect(inputContainer).toHaveScreenshot('message-input.png', {
      threshold: 0.1
    });
  });

  test('should match user message design', async ({ page }) => {
    // Send a test message
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('This is a test user message for visual regression testing');
    await messageInput.press('Enter');
    
    // Wait for message to appear
    await page.waitForSelector('.user-message', { timeout: 5000 });
    
    const userMessage = page.locator('.user-message').first();
    await expect(userMessage).toHaveScreenshot('user-message.png', {
      threshold: 0.1
    });
  });

  test('should match assistant message design', async ({ page }) => {
    // Send a message and wait for response
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Hello');
    await messageInput.press('Enter');
    
    // Wait for assistant response
    await page.waitForSelector('.assistant-content', { timeout: 30000 });
    
    const assistantMessage = page.locator('.assistant-content').last();
    await expect(assistantMessage).toHaveScreenshot('assistant-message.png', {
      threshold: 0.2
    });
  }, 45000);

  test('should match thinking indicator design', async ({ page }) => {
    // Send a message to trigger thinking indicator
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Test thinking');
    await messageInput.press('Enter');
    
    // Wait for thinking indicator
    await page.waitForSelector('.thinking', { timeout: 5000 });
    
    const thinkingIndicator = page.locator('.thinking');
    await expect(thinkingIndicator).toHaveScreenshot('thinking-indicator.png', {
      threshold: 0.1
    });
  });

  // ========================================
  // 🎛️ Model Selection Screenshots
  // ========================================

  test('should match model selector design', async ({ page }) => {
    const modelSelector = page.locator('.model-selector');
    await expect(modelSelector).toHaveScreenshot('model-selector.png', {
      threshold: 0.1
    });
  });

  test('should match model list design', async ({ page }) => {
    const gptList = page.locator('.gpt-list');
    await expect(gptList).toHaveScreenshot('model-list.png', {
      threshold: 0.1
    });
  });

  test('should match active model design', async ({ page }) => {
    // Click on a model to make it active
    const firstModel = page.locator('.gpt-item').first();
    await firstModel.click();
    
    await expect(firstModel).toHaveScreenshot('active-model.png', {
      threshold: 0.1
    });
  });

  // ========================================
  // 📱 Responsive Design Screenshots
  // ========================================

  test('should match mobile layout', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(500); // Wait for layout to adjust
    
    await expect(page).toHaveScreenshot('mobile-layout.png', {
      fullPage: true,
      threshold: 0.3
    });
  });

  test('should match tablet layout', async ({ page }) => {
    // Set tablet viewport
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.waitForTimeout(500);
    
    await expect(page).toHaveScreenshot('tablet-layout.png', {
      fullPage: true,
      threshold: 0.3
    });
  });

  test('should match desktop large layout', async ({ page }) => {
    // Set large desktop viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.waitForTimeout(500);
    
    await expect(page).toHaveScreenshot('desktop-large-layout.png', {
      fullPage: true,
      threshold: 0.3
    });
  });

  // ========================================
  // 🎨 Theme and Color Screenshots
  // ========================================

  test('should match dark theme colors', async ({ page }) => {
    // Verify dark theme is active (default)
    const body = page.locator('body');
    const backgroundColor = await body.evaluate(el => 
      getComputedStyle(el).backgroundColor
    );
    
    // Should be dark
    expect(backgroundColor).toContain('rgb(13, 13, 13)');
    
    await expect(page).toHaveScreenshot('dark-theme.png', {
      fullPage: true,
      threshold: 0.2
    });
  });

  test('should match brand colors', async ({ page }) => {
    const logo = page.locator('.logo');
    await expect(logo).toHaveScreenshot('brand-logo.png', {
      threshold: 0.1
    });
    
    const sendButton = page.locator('#sendButton');
    await expect(sendButton).toHaveScreenshot('send-button.png', {
      threshold: 0.1
    });
  });

  // ========================================
  // ✨ Animation Screenshots
  // ========================================

  test('should match hover states', async ({ page }) => {
    // Test hover on model item
    const modelItem = page.locator('.gpt-item').first();
    await modelItem.hover();
    await page.waitForTimeout(300); // Wait for hover animation
    
    await expect(modelItem).toHaveScreenshot('model-item-hover.png', {
      threshold: 0.2
    });
  });

  test('should match send button hover', async ({ page }) => {
    const sendButton = page.locator('#sendButton');
    await sendButton.hover();
    await page.waitForTimeout(300);
    
    await expect(sendButton).toHaveScreenshot('send-button-hover.png', {
      threshold: 0.2
    });
  });

  test('should match new chat button hover', async ({ page }) => {
    const newChatButton = page.locator('.action-item').first();
    await newChatButton.hover();
    await page.waitForTimeout(300);
    
    await expect(newChatButton).toHaveScreenshot('new-chat-hover.png', {
      threshold: 0.2
    });
  });

  // ========================================
  // 🌟 Special States Screenshots
  // ========================================

  test('should match loading state', async ({ page }) => {
    // Send message to trigger loading
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Loading test');
    await messageInput.press('Enter');
    
    // Capture during loading
    await page.waitForTimeout(500);
    
    await expect(page).toHaveScreenshot('loading-state.png', {
      fullPage: true,
      threshold: 0.3
    });
  });

  test('should match conversation with multiple messages', async ({ page }) => {
    // Create a conversation
    const messageInput = page.locator('#messageInput');
    
    // Send multiple messages
    await messageInput.fill('Hello Wisbee');
    await messageInput.press('Enter');
    await page.waitForSelector('.assistant-content', { timeout: 30000 });
    
    await messageInput.fill('How are you?');
    await messageInput.press('Enter');
    await page.waitForSelector('.assistant-content:nth-of-type(4)', { timeout: 30000 });
    
    await expect(page).toHaveScreenshot('conversation-multiple-messages.png', {
      fullPage: true,
      threshold: 0.3
    });
  }, 90000);

  // ========================================
  // 🔧 Cross-browser Consistency
  // ========================================

  test('should be consistent across different zoom levels', async ({ page }) => {
    // Test at 150% zoom
    await page.evaluate(() => {
      document.body.style.zoom = '1.5';
    });
    await page.waitForTimeout(500);
    
    await expect(page).toHaveScreenshot('zoom-150.png', {
      fullPage: true,
      threshold: 0.4
    });
    
    // Reset zoom
    await page.evaluate(() => {
      document.body.style.zoom = '1';
    });
  });
});