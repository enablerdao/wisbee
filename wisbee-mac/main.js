const { app, BrowserWindow, Menu, ipcMain, shell, dialog } = require('electron');
const path = require('path');
const { spawn, exec } = require('child_process');
const http = require('http');
const fs = require('fs');

// Reduce memory usage
app.disableHardwareAcceleration();
app.commandLine.appendSwitch('js-flags', '--max-old-space-size=256');
app.commandLine.appendSwitch('disable-gpu');
app.commandLine.appendSwitch('disable-gpu-sandbox');
app.commandLine.appendSwitch('no-sandbox');
app.commandLine.appendSwitch('disable-dev-shm-usage');

let mainWindow;
let serverProcess;
let ollamaStatus = 'checking';

// Check if Ollama is installed and running
async function checkOllamaStatus() {
  return new Promise((resolve) => {
    exec('ollama list', (error, stdout, stderr) => {
      if (error) {
        ollamaStatus = 'not-installed';
        resolve(false);
      } else {
        ollamaStatus = 'ready';
        // Check if default model exists
        checkDefaultModel(stdout);
        resolve(true);
      }
    });
  });
}

// Check if default model is installed
function checkDefaultModel(modelsList) {
  const defaultModel = 'jaahas/qwen3-abliterated:0.6b';
  const hasDefaultModel = modelsList.includes(defaultModel.split(':')[0]);
  
  if (!hasDefaultModel && mainWindow) {
    // Send event to frontend to trigger download
    mainWindow.webContents.send('default-model-missing', defaultModel);
  }
}

// Start the Python server
function startServer() {
  const serverPath = path.join(__dirname, 'ollama-webui-server.py');
  
  // Check if Python server file exists
  if (!fs.existsSync(serverPath)) {
    console.error('Python server file not found:', serverPath);
    dialog.showErrorBox('Server Error', 'Python server file not found');
    return;
  }
  
  try {
    serverProcess = spawn('python3', [serverPath, '8899'], {
      stdio: ['pipe', 'pipe', 'pipe'],
      detached: false
    });
    
    serverProcess.stdout.on('data', (data) => {
      console.log(`Server: ${data}`);
    });
    
    serverProcess.stderr.on('data', (data) => {
      const errorStr = data.toString();
      console.error(`Server Error: ${errorStr}`);
      // Ignore non-critical errors
      if (!errorStr.includes('Address already in use')) {
        // Don't show dialog for every stderr output
      }
    });
    
    serverProcess.on('error', (error) => {
      console.error('Failed to start server:', error);
      // Only show dialog for critical errors
      if (error.code === 'ENOENT') {
        dialog.showErrorBox('Python Not Found', 'Python3 is required to run the server');
      }
    });
    
    serverProcess.on('exit', (code) => {
      console.log(`Server exited with code ${code}`);
      if (code !== 0 && code !== null && mainWindow) {
        // Don't show dialog, just log
        console.error(`Server exited with code ${code}`);
      }
    });
  } catch (error) {
    console.error('Error spawning server:', error);
  }
}

// Create the main application window
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    icon: path.join(__dirname, 'assets/icon.png'),
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      webSecurity: false,
      webgl: false,
      images: true
    },
    titleBarStyle: 'hiddenInset',
    backgroundColor: '#0a0a0a',
    show: false
  });

  // Create menu
  createMenu();

  // Load the app
  mainWindow.loadFile('index.html');

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    console.log('Window ready to show');
    mainWindow.show();
  });
  
  // Handle renderer crashes
  mainWindow.webContents.on('crashed', (event, killed) => {
    console.error('Renderer crashed!', killed);
    if (!killed) {
      mainWindow.reload();
    }
  });
  
  // Handle unresponsive
  mainWindow.on('unresponsive', () => {
    console.error('Window became unresponsive');
  });
  
  // Fallback: Show window after a delay if ready-to-show doesn't fire
  setTimeout(() => {
    if (mainWindow && !mainWindow.isVisible()) {
      console.log('Force showing window');
      mainWindow.show();
    }
  }, 3000);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// Create application menu
function createMenu() {
  const template = [
    {
      label: 'Wisbee',
      submenu: [
        { label: 'About Wisbee', role: 'about' },
        { type: 'separator' },
        { label: 'Preferences...', accelerator: 'Cmd+,', click: () => showPreferences() },
        { type: 'separator' },
        { label: 'Quit Wisbee', accelerator: 'Cmd+Q', role: 'quit' }
      ]
    },
    {
      label: 'Edit',
      submenu: [
        { label: 'Undo', accelerator: 'Cmd+Z', role: 'undo' },
        { label: 'Redo', accelerator: 'Shift+Cmd+Z', role: 'redo' },
        { type: 'separator' },
        { label: 'Cut', accelerator: 'Cmd+X', role: 'cut' },
        { label: 'Copy', accelerator: 'Cmd+C', role: 'copy' },
        { label: 'Paste', accelerator: 'Cmd+V', role: 'paste' },
        { label: 'Select All', accelerator: 'Cmd+A', role: 'selectAll' }
      ]
    },
    {
      label: 'Models',
      submenu: [
        { label: 'Manage Models...', accelerator: 'Cmd+M', click: () => showModelManager() },
        { label: 'Download Model...', click: () => showModelDownloader() },
        { type: 'separator' },
        { label: 'Refresh Model List', click: () => refreshModels() }
      ]
    },
    {
      label: 'Chat',
      submenu: [
        { label: 'New Chat', accelerator: 'Cmd+N', click: () => newChat() },
        { label: 'Clear Chat', accelerator: 'Cmd+K', click: () => clearChat() },
        { type: 'separator' },
        { label: 'Export Chat...', click: () => exportChat() }
      ]
    },
    {
      label: 'Window',
      submenu: [
        { label: 'Minimize', accelerator: 'Cmd+M', role: 'minimize' },
        { label: 'Close', accelerator: 'Cmd+W', role: 'close' }
      ]
    },
    {
      label: 'Help',
      submenu: [
        { label: 'Documentation', click: () => shell.openExternal('https://github.com/enablerdao/wisbee') },
        { label: 'Report Issue', click: () => shell.openExternal('https://github.com/enablerdao/wisbee/issues') }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

// IPC handlers for model management
ipcMain.handle('get-models', async () => {
  return new Promise((resolve) => {
    exec('ollama list', (error, stdout, stderr) => {
      if (error) {
        resolve([]);
        return;
      }
      
      const lines = stdout.split('\n').slice(1); // Skip header
      const models = lines
        .filter(line => line.trim())
        .map(line => {
          const parts = line.split(/\s+/);
          return {
            name: parts[0],
            id: parts[1],
            size: parts[2],
            modified: parts.slice(3).join(' ')
          };
        });
      
      resolve(models);
    });
  });
});

ipcMain.handle('pull-model', async (event, modelName) => {
  return new Promise((resolve) => {
    const pullProcess = spawn('ollama', ['pull', modelName]);
    
    pullProcess.stdout.on('data', (data) => {
      mainWindow.webContents.send('pull-progress', data.toString());
    });
    
    pullProcess.stderr.on('data', (data) => {
      mainWindow.webContents.send('pull-error', data.toString());
    });
    
    pullProcess.on('close', (code) => {
      resolve(code === 0);
    });
  });
});

ipcMain.handle('delete-model', async (event, modelName) => {
  return new Promise((resolve) => {
    exec(`ollama rm ${modelName}`, (error) => {
      resolve(!error);
    });
  });
});

ipcMain.handle('check-ollama', checkOllamaStatus);

// Window management functions
function showModelManager() {
  mainWindow.webContents.send('show-model-manager');
}

function showModelDownloader() {
  mainWindow.webContents.send('show-model-downloader');
}

function showPreferences() {
  mainWindow.webContents.send('show-preferences');
}

function refreshModels() {
  mainWindow.webContents.send('refresh-models');
}

function newChat() {
  mainWindow.webContents.send('new-chat');
}

function clearChat() {
  mainWindow.webContents.send('clear-chat');
}

function exportChat() {
  mainWindow.webContents.send('export-chat');
}

// App event handlers
app.whenReady().then(async () => {
  try {
    console.log('App is ready, starting server...');
    startServer();
    
    // Wait a bit for server to start
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    console.log('Creating window...');
    createWindow();
    
    console.log('Checking Ollama status...');
    await checkOllamaStatus();
  } catch (error) {
    console.error('Error during app initialization:', error);
    dialog.showErrorBox('Initialization Error', `Failed to start app: ${error.message}`);
    app.quit();
  }
});

app.on('window-all-closed', () => {
  if (serverProcess) {
    serverProcess.kill();
  }
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

app.on('before-quit', () => {
  if (serverProcess) {
    serverProcess.kill();
  }
});