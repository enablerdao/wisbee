const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    x: 100,
    y: 100,
    show: true,
    frame: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  win.loadURL('data:text/html,<h1 style="color: red;">Electron Test Window</h1><p>If you can see this, Electron is working!</p>');
  
  // Force focus
  win.focus();
  win.moveTop();
});

app.on('window-all-closed', () => {
  app.quit();
});