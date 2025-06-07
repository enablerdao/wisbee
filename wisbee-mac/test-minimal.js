const { app, BrowserWindow } = require('electron');

app.disableHardwareAcceleration();
app.commandLine.appendSwitch('no-sandbox');
app.commandLine.appendSwitch('disable-gpu');
app.commandLine.appendSwitch('disable-software-rasterizer');

app.whenReady().then(() => {
  console.log('Creating window...');
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    show: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });
  
  win.loadURL('data:text/html,<h1>Wisbee Test</h1><p>Window is working!</p>');
  
  win.on('ready-to-show', () => {
    console.log('Window ready to show');
    win.show();
  });
  
  win.webContents.on('did-finish-load', () => {
    console.log('Content loaded');
  });
  
  win.webContents.on('crashed', () => {
    console.log('Renderer crashed!');
  });
});

app.on('window-all-closed', () => {
  app.quit();
});