const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

let mainWindow;
let pythonServer;

function startPythonServer() {
  const serverPath = path.join(__dirname, '..', 'ollama-webui-server.py');
  pythonServer = spawn('python3', [serverPath], {
    cwd: path.join(__dirname, '..'),
    env: { ...process.env, PYTHONUNBUFFERED: '1' }
  });

  pythonServer.stdout.on('data', (data) => {
    console.log(`Server: ${data}`);
  });

  pythonServer.stderr.on('data', (data) => {
    console.error(`Server Error: ${data}`);
  });

  pythonServer.on('close', (code) => {
    console.log(`Python server exited with code ${code}`);
  });
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    icon: path.join(__dirname, 'assets', 'icon.png'),
    titleBarStyle: 'hiddenInset',
    show: false
  });

  // Wait for server to start before loading
  setTimeout(() => {
    mainWindow.loadURL('http://localhost:8899');
    mainWindow.show();
  }, 3000);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // Create application menu
  const template = [
    {
      label: 'Ollama Chat',
      submenu: [
        { label: 'About Ollama Chat', role: 'about' },
        { type: 'separator' },
        { label: 'Quit', accelerator: 'Command+Q', click: () => app.quit() }
      ]
    },
    {
      label: 'Edit',
      submenu: [
        { label: 'Undo', accelerator: 'Command+Z', role: 'undo' },
        { label: 'Redo', accelerator: 'Shift+Command+Z', role: 'redo' },
        { type: 'separator' },
        { label: 'Cut', accelerator: 'Command+X', role: 'cut' },
        { label: 'Copy', accelerator: 'Command+C', role: 'copy' },
        { label: 'Paste', accelerator: 'Command+V', role: 'paste' },
        { label: 'Select All', accelerator: 'Command+A', role: 'selectAll' }
      ]
    },
    {
      label: 'View',
      submenu: [
        { label: 'Reload', accelerator: 'Command+R', click: () => mainWindow.reload() },
        { label: 'Toggle Developer Tools', accelerator: 'Option+Command+I', click: () => mainWindow.webContents.toggleDevTools() },
        { type: 'separator' },
        { label: 'Actual Size', accelerator: 'Command+0', role: 'resetZoom' },
        { label: 'Zoom In', accelerator: 'Command+Plus', role: 'zoomIn' },
        { label: 'Zoom Out', accelerator: 'Command+-', role: 'zoomOut' },
        { type: 'separator' },
        { label: 'Toggle Fullscreen', accelerator: 'Control+Command+F', role: 'togglefullscreen' }
      ]
    },
    {
      label: 'Window',
      submenu: [
        { label: 'Minimize', accelerator: 'Command+M', role: 'minimize' },
        { label: 'Close', accelerator: 'Command+W', role: 'close' }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

app.on('ready', () => {
  startPythonServer();
  createWindow();
});

app.on('window-all-closed', () => {
  if (pythonServer) {
    pythonServer.kill();
  }
  app.quit();
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

app.on('before-quit', () => {
  if (pythonServer) {
    pythonServer.kill();
  }
});