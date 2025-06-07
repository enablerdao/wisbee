const { app, BrowserWindow, Menu, ipcMain, shell } = require('electron');
const path = require('path');
const { spawn, exec } = require('child_process');
const fs = require('fs');
const https = require('https');

let mainWindow;
let setupWindow;
let pythonServer;
let ollamaProcess;

// Check if first run
function isFirstRun() {
  const configPath = path.join(app.getPath('userData'), 'app-config.json');
  return !fs.existsSync(configPath);
}

// Save first run status
function saveFirstRunComplete() {
  const configPath = path.join(app.getPath('userData'), 'app-config.json');
  fs.writeFileSync(configPath, JSON.stringify({ firstRun: false, setupComplete: true }));
}

// Check if Ollama is installed
async function checkOllama() {
  return new Promise((resolve) => {
    exec('which ollama', (error) => {
      resolve(!error);
    });
  });
}

// Install Ollama
async function installOllama() {
  return new Promise((resolve) => {
    const installScript = `
      curl -fsSL https://ollama.ai/install.sh -o /tmp/ollama-install.sh
      chmod +x /tmp/ollama-install.sh
      /tmp/ollama-install.sh
    `;
    
    exec(installScript, (error) => {
      resolve(!error);
    });
  });
}

// Start Ollama server
async function startOllamaServer() {
  return new Promise((resolve) => {
    // Check if already running
    exec('curl -s http://localhost:11434/api/tags', (error) => {
      if (!error) {
        resolve(true);
        return;
      }
      
      // Start Ollama
      ollamaProcess = spawn('ollama', ['serve'], {
        detached: true,
        stdio: 'ignore'
      });
      
      ollamaProcess.unref();
      
      // Wait for server to start
      setTimeout(() => {
        exec('curl -s http://localhost:11434/api/tags', (error) => {
          resolve(!error);
        });
      }, 3000);
    });
  });
}

// Download model
async function downloadModel(modelName) {
  return new Promise((resolve) => {
    const pullProcess = spawn('ollama', ['pull', modelName]);
    
    pullProcess.on('close', (code) => {
      resolve(code === 0);
    });
  });
}

// Start Python server
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
}

// Create setup window
function createSetupWindow() {
  setupWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    },
    titleBarStyle: 'hiddenInset',
    show: false
  });

  setupWindow.loadFile(path.join(__dirname, 'setup-wizard.html'));
  
  setupWindow.once('ready-to-show', () => {
    setupWindow.show();
  });

  setupWindow.on('closed', () => {
    setupWindow = null;
  });
}

// Create main window
function createMainWindow() {
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

  // Start Python server
  startPythonServer();

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

// IPC handlers
ipcMain.handle('check-ollama', checkOllama);
ipcMain.handle('install-ollama', installOllama);
ipcMain.handle('start-ollama', startOllamaServer);
ipcMain.handle('download-model', async (event, modelName) => {
  return await downloadModel(modelName);
});

ipcMain.on('setup-complete', () => {
  saveFirstRunComplete();
  if (setupWindow) {
    setupWindow.close();
  }
  createMainWindow();
});

// App event handlers
app.on('ready', () => {
  if (isFirstRun()) {
    createSetupWindow();
  } else {
    // Check if Ollama is running
    startOllamaServer().then(() => {
      createMainWindow();
    });
  }
});

app.on('window-all-closed', () => {
  if (pythonServer) {
    pythonServer.kill();
  }
  app.quit();
});

app.on('activate', () => {
  if (mainWindow === null && !setupWindow) {
    createMainWindow();
  }
});

app.on('before-quit', () => {
  if (pythonServer) {
    pythonServer.kill();
  }
});