// Test setup for Jest
global.marked = {
  parse: jest.fn((text) => text)
};

global.Prism = {
  highlightAllUnder: jest.fn()
};

// Mock fetch for tests
global.fetch = jest.fn();

// Mock console methods in tests
global.console = {
  ...console,
  warn: jest.fn(),
  error: jest.fn(),
  log: jest.fn()
};