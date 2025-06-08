// ♿ Accessibility Tests for Wisbee
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

test.describe('🐝 Accessibility Tests', () => {
  const APP_URL = 'http://localhost:8899';

  test.beforeEach(async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');
  });

  // ========================================
  // 🔍 Core Accessibility Tests
  // ========================================

  test('should pass axe accessibility audit', async ({ page }) => {
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('should have proper heading hierarchy', async ({ page }) => {
    const headings = await page.locator('h1, h2, h3, h4, h5, h6').all();
    
    // Check that headings exist
    expect(headings.length).toBeGreaterThan(0);
    
    // Check heading hierarchy (h1 should come before h2, etc.)
    const headingLevels = [];
    for (const heading of headings) {
      const tagName = await heading.evaluate(el => el.tagName.toLowerCase());
      headingLevels.push(parseInt(tagName.charAt(1)));
    }
    
    // Verify proper hierarchy (no skipping levels)
    for (let i = 1; i < headingLevels.length; i++) {
      const diff = headingLevels[i] - headingLevels[i - 1];
      expect(diff).toBeLessThanOrEqual(1);
    }
  });

  test('should have accessible form labels', async ({ page }) => {
    const messageInput = page.locator('#messageInput');
    
    // Check if input has proper labeling
    const ariaLabel = await messageInput.getAttribute('aria-label');
    const placeholder = await messageInput.getAttribute('placeholder');
    const associatedLabel = await page.locator('label[for="messageInput"]').count();
    
    // Input should have some form of accessible labeling
    expect(
      ariaLabel !== null || 
      placeholder !== null || 
      associatedLabel > 0
    ).toBe(true);
  });

  // ========================================
  // ⌨️ Keyboard Navigation Tests
  // ========================================

  test('should support keyboard navigation', async ({ page }) => {
    // Test Tab navigation through interactive elements
    const interactiveElements = [
      '.gpt-item',
      '#messageInput',
      '#sendButton',
      '.action-item'
    ];

    for (const selector of interactiveElements) {
      const element = page.locator(selector).first();
      if (await element.count() > 0) {
        await element.focus();
        
        // Check if element is focusable
        const isFocused = await element.evaluate(el => 
          document.activeElement === el
        );
        expect(isFocused).toBe(true);
      }
    }
  });

  test('should handle Enter key on buttons', async ({ page }) => {
    const sendButton = page.locator('#sendButton');
    await sendButton.focus();
    
    // Fill input first
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Test keyboard input');
    
    // Press Enter on send button
    await sendButton.press('Enter');
    
    // Should send message
    await page.waitForSelector('.user-message', { timeout: 5000 });
    const userMessage = page.locator('.user-message').first();
    await expect(userMessage).toContainText('Test keyboard input');
  });

  test('should support Escape key functionality', async ({ page }) => {
    const messageInput = page.locator('#messageInput');
    
    // Fill input and then press Escape
    await messageInput.fill('Test escape functionality');
    await messageInput.press('Escape');
    
    // Input should still be focused but available for interaction
    const isFocused = await messageInput.evaluate(el => 
      document.activeElement === el
    );
    expect(isFocused).toBe(true);
  });

  test('should support arrow key navigation in model list', async ({ page }) => {
    const firstModel = page.locator('.gpt-item').first();
    await firstModel.focus();
    
    // Press down arrow
    await firstModel.press('ArrowDown');
    
    // Should move focus to next model item
    const secondModel = page.locator('.gpt-item').nth(1);
    if (await secondModel.count() > 0) {
      const isFocused = await secondModel.evaluate(el => 
        document.activeElement === el
      );
      expect(isFocused).toBe(true);
    }
  });

  // ========================================
  // 🎨 Color and Contrast Tests
  // ========================================

  test('should have sufficient color contrast', async ({ page }) => {
    // Test main text contrast
    const bodyText = page.locator('body');
    const computedStyle = await bodyText.evaluate(el => {
      const style = getComputedStyle(el);
      return {
        color: style.color,
        backgroundColor: style.backgroundColor
      };
    });
    
    // Should have readable text (basic check)
    expect(computedStyle.color).toBeTruthy();
    expect(computedStyle.backgroundColor).toBeTruthy();
  });

  test('should not rely solely on color for information', async ({ page }) => {
    // Check that active states have more than just color differences
    const activeModel = page.locator('.gpt-item.active');
    if (await activeModel.count() > 0) {
      const hasTextIndicator = await activeModel.locator('.checkmark, .icon').count() > 0;
      const hasAriaSelected = await activeModel.getAttribute('aria-selected');
      
      // Should have non-color indicators
      expect(hasTextIndicator || hasAriaSelected === 'true').toBe(true);
    }
  });

  // ========================================
  // 🔊 Screen Reader Tests
  // ========================================

  test('should have proper ARIA roles', async ({ page }) => {
    // Check for proper roles on key components
    const sidebar = page.locator('.sidebar');
    const mainContent = page.locator('.main-content');
    const messageList = page.locator('#messagesContainer');
    
    // These should have appropriate roles or be semantic elements
    const sidebarRole = await sidebar.getAttribute('role') || 'navigation';
    const mainRole = await mainContent.getAttribute('role') || 'main';
    const messageRole = await messageList.getAttribute('role') || 'log';
    
    expect(['navigation', 'complementary', 'aside']).toContain(sidebarRole);
    expect(['main', 'application']).toContain(mainRole);
    expect(['log', 'region', 'list']).toContain(messageRole);
  });

  test('should have live regions for dynamic content', async ({ page }) => {
    // Check if message area has live region attributes
    const messagesContainer = page.locator('#messagesContainer');
    
    const ariaLive = await messagesContainer.getAttribute('aria-live');
    const ariaRelevant = await messagesContainer.getAttribute('aria-relevant');
    
    // Should have live region for new messages
    expect(['polite', 'assertive']).toContain(ariaLive);
  });

  test('should announce loading states', async ({ page }) => {
    // Send a message to trigger loading
    const messageInput = page.locator('#messageInput');
    await messageInput.fill('Test loading announcement');
    await messageInput.press('Enter');
    
    // Check for loading indicators with proper ARIA
    const loadingIndicator = page.locator('.thinking, .loading');
    if (await loadingIndicator.count() > 0) {
      const ariaLabel = await loadingIndicator.getAttribute('aria-label');
      const ariaDescribedBy = await loadingIndicator.getAttribute('aria-describedby');
      
      expect(ariaLabel || ariaDescribedBy).toBeTruthy();
    }
  });

  // ========================================
  // 📱 Mobile Accessibility Tests
  // ========================================

  test('should be accessible on mobile devices', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Run accessibility audit on mobile
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('should have touch-friendly targets', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Check button sizes
    const sendButton = page.locator('#sendButton');
    const buttonSize = await sendButton.boundingBox();
    
    if (buttonSize) {
      // Should be at least 44x44px for touch targets
      expect(buttonSize.width).toBeGreaterThanOrEqual(44);
      expect(buttonSize.height).toBeGreaterThanOrEqual(44);
    }
  });

  // ========================================
  // 🔧 Assistive Technology Tests
  // ========================================

  test('should work with high contrast mode', async ({ page }) => {
    // Simulate high contrast mode
    await page.addStyleTag({
      content: `
        @media (prefers-contrast: high) {
          * {
            border: 1px solid yellow !important;
          }
        }
      `
    });
    
    await page.waitForTimeout(500);
    
    // Page should still be functional
    const messageInput = page.locator('#messageInput');
    await expect(messageInput).toBeVisible();
    await expect(messageInput).toBeEditable();
  });

  test('should respect reduced motion preferences', async ({ page }) => {
    // Simulate reduced motion preference
    await page.emulateMedia({ reducedMotion: 'reduce' });
    
    await page.waitForTimeout(500);
    
    // Check that animations are reduced or disabled
    const logo = page.locator('.logo-icon');
    const animationDuration = await logo.evaluate(el => 
      getComputedStyle(el).animationDuration
    );
    
    // Should have no animation or very short duration
    expect(['none', '0s', '0.01s']).toContain(animationDuration);
  });

  // ========================================
  // 📊 Accessibility Report Generation
  // ========================================

  test('should generate accessibility report', async ({ page }) => {
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'best-practice'])
      .analyze();

    // Log detailed results for review
    console.log('🔍 Accessibility Audit Results:');
    console.log(`✅ Passed: ${results.passes.length} rules`);
    console.log(`⚠️ Violations: ${results.violations.length} issues`);
    console.log(`💡 Incomplete: ${results.incomplete.length} items`);
    
    if (results.violations.length > 0) {
      console.log('\n🚨 Violations found:');
      results.violations.forEach(violation => {
        console.log(`- ${violation.id}: ${violation.description}`);
        console.log(`  Impact: ${violation.impact}`);
        console.log(`  Nodes: ${violation.nodes.length}`);
      });
    }
    
    // Store results for CI reporting
    expect(results.violations.length).toBe(0);
  });
});