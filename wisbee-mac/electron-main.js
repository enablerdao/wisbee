const { app, BrowserWindow, Menu, shell, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');
const os = require('os');

let mainWindow;
let serverProcess;

// Enable DevTools in production for debugging
app.commandLine.appendSwitch('enable-logging');

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        minWidth: 800,
        minHeight: 600,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'app-preload.js')
        },
        titleBarStyle: 'hiddenInset',
        icon: path.join(__dirname, 'assets', 'icon.png')
    });

    // Create menu
    const template = [
        {
            label: 'Wisbee',
            submenu: [
                {
                    label: 'About Wisbee',
                    click: () => {
                        dialog.showMessageBox(mainWindow, {
                            type: 'info',
                            title: 'About Wisbee',
                            message: 'Wisbee - Enhanced Ollama Chat',
                            detail: 'A beautiful chat interface for Ollama with markdown support, syntax highlighting, and thinking visualization.\n\nVersion: 1.0.0',
                            buttons: ['OK']
                        });
                    }
                },
                { type: 'separator' },
                { role: 'services', submenu: [] },
                { type: 'separator' },
                { role: 'hide' },
                { role: 'hideOthers' },
                { role: 'unhide' },
                { type: 'separator' },
                { role: 'quit' }
            ]
        },
        {
            label: 'Edit',
            submenu: [
                { role: 'undo' },
                { role: 'redo' },
                { type: 'separator' },
                { role: 'cut' },
                { role: 'copy' },
                { role: 'paste' },
                { role: 'pasteAndMatchStyle' },
                { role: 'delete' },
                { role: 'selectAll' }
            ]
        },
        {
            label: 'View',
            submenu: [
                { role: 'reload' },
                { role: 'forceReload' },
                { role: 'toggleDevTools' },
                { type: 'separator' },
                { role: 'resetZoom' },
                { role: 'zoomIn' },
                { role: 'zoomOut' },
                { type: 'separator' },
                { role: 'togglefullscreen' }
            ]
        },
        {
            label: 'Window',
            submenu: [
                { role: 'minimize' },
                { role: 'close' },
                { role: 'zoom' },
                { type: 'separator' },
                { role: 'front' }
            ]
        },
        {
            label: 'Help',
            submenu: [
                {
                    label: 'Ollama Documentation',
                    click: () => {
                        shell.openExternal('https://ollama.ai');
                    }
                },
                {
                    label: 'Download Models',
                    click: () => {
                        shell.openExternal('https://ollama.ai/library');
                    }
                },
                { type: 'separator' },
                {
                    label: 'Check Ollama Status',
                    click: async () => {
                        const isRunning = await checkOllama();
                        dialog.showMessageBox(mainWindow, {
                            type: isRunning ? 'info' : 'warning',
                            title: 'Ollama Status',
                            message: isRunning ? 'Ollama is running' : 'Ollama is not running',
                            detail: isRunning 
                                ? 'Ollama server is running on port 11434' 
                                : 'Please install and start Ollama from https://ollama.ai',
                            buttons: ['OK']
                        });
                    }
                }
            ]
        }
    ];

    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);

    // Start the server
    startServer();

    // Wait a bit for server to start, then load the app
    setTimeout(() => {
        mainWindow.loadURL('http://localhost:8899');
    }, 1000);

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

function startServer() {
    // Use Node.js server for App Store compatibility
    try {
        require('./server.js');
        console.log('Node.js server started');
    } catch (error) {
        console.error('Failed to start server:', error);
        // Fallback to Python server
        const serverPath = path.join(__dirname, 'enhanced-server.py');
        const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';
        
        serverProcess = spawn(pythonCmd, [serverPath], {
            cwd: __dirname,
            env: { ...process.env, PYTHONUNBUFFERED: '1' }
        });

        serverProcess.stdout.on('data', (data) => {
            console.log(`Server: ${data}`);
        });

        serverProcess.stderr.on('data', (data) => {
            console.error(`Server Error: ${data}`);
        });

        serverProcess.on('close', (code) => {
            console.log(`Server exited with code ${code}`);
            if (code !== 0 && mainWindow) {
                setTimeout(startServer, 2000);
            }
        });
    }
}

async function checkOllama() {
    try {
        const response = await fetch('http://localhost:11434/api/tags');
        return response.ok;
    } catch (error) {
        return false;
    }
}

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (serverProcess) {
        serverProcess.kill();
    }
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('before-quit', () => {
    if (serverProcess) {
        serverProcess.kill();
    }
});

// Handle certificate errors
app.on('certificate-error', (event, webContents, url, error, certificate, callback) => {
    event.preventDefault();
    callback(true);
});

// Handle permission requests
app.on('web-contents-created', (event, contents) => {
    contents.on('permission-request', (event, permission, callback) => {
        callback(true);
    });
});