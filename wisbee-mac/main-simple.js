const { app, BrowserWindow } = require('electron');
const path = require('path');

// Disable hardware acceleration to reduce memory usage
app.disableHardwareAcceleration();

// Set memory limits
app.commandLine.appendSwitch('js-flags', '--max-old-space-size=512');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  // Load simple HTML first
  mainWindow.loadFile('simple.html');

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  app.quit();
});