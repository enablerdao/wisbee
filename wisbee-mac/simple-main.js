const { app, BrowserWindow } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    show: true,  // Show immediately
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  // Load a simple HTML content directly
  mainWindow.loadURL(`data:text/html,
    <html>
      <body style="background: #0a0a0a; color: white; font-family: system-ui;">
        <h1>Wisbee Test</h1>
        <p>If you can see this, the window is working!</p>
        <iframe src="http://localhost:8899" style="width: 100%; height: 600px; border: none;"></iframe>
      </body>
    </html>
  `);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  app.quit();
});