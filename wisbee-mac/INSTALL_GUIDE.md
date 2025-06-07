# Wisbee Installation Guide

## 📦 Download

Visit [wisbee.ai](https://wisbee.ai) to download the latest version for your platform.

## 🍎 macOS Installation

1. Download the `.dmg` file from wisbee.ai
2. Double-click the downloaded file
3. Drag Wisbee to your Applications folder
4. First launch: Right-click and select "Open" (security prompt)
5. Follow the setup wizard to install Ollama if needed

### Requirements
- macOS 10.15 (Catalina) or later
- 4GB RAM minimum
- 2GB free disk space

## 🪟 Windows Installation

1. Download the `.exe` installer from wisbee.ai
2. Run the installer
3. Follow the installation wizard
4. Launch Wisbee from Start Menu or Desktop
5. The app will guide you through Ollama setup

### Requirements
- Windows 10 or Windows 11
- 4GB RAM minimum
- 2GB free disk space
- 64-bit or 32-bit system

### Windows Security Note
Windows Defender may show a warning. Click "More info" → "Run anyway" (the app is safe but not yet signed).

## 🐧 Linux Installation

### AppImage (Recommended)
1. Download the `.AppImage` file from wisbee.ai
2. Make it executable:
   ```bash
   chmod +x Wisbee-*.AppImage
   ```
3. Run the AppImage:
   ```bash
   ./Wisbee-*.AppImage
   ```

### Debian/Ubuntu (.deb)
```bash
# Download the .deb file
wget https://github.com/enablerdao/wisbee/releases/download/v1.0.0/wisbee_1.0.0_amd64.deb

# Install
sudo dpkg -i wisbee_1.0.0_amd64.deb

# Fix dependencies if needed
sudo apt-get install -f
```

### Fedora/RHEL (.rpm)
```bash
# Download the .rpm file
wget https://github.com/enablerdao/wisbee/releases/download/v1.0.0/wisbee-1.0.0.x86_64.rpm

# Install
sudo rpm -i wisbee-1.0.0.x86_64.rpm
```

### Requirements
- Linux kernel 3.10 or later
- 4GB RAM minimum
- 2GB free disk space
- X11 or Wayland display server

## 📱 iOS Installation

1. Search for "Wisbee" in the App Store
2. Tap "Get" to install
3. Open the app
4. Grant necessary permissions when prompted

### Requirements
- iOS 16.0 or later
- iPhone or iPad
- 200MB free space

### iOS Features
- On-device LLM execution (qwen3-abliterated:0.6b)
- Connect to Mac's Ollama server for more models
- Dark mode support
- Haptic feedback

## 🚀 First Launch

### Desktop (Windows/macOS/Linux)
1. Launch Wisbee
2. The setup wizard will check for Ollama
3. If not installed, follow the automated installation
4. Select your preferred model
5. Start chatting!

### iOS
1. Open Wisbee
2. Choose between:
   - Local mode (on-device model)
   - Remote mode (connect to Mac's Ollama)
3. For remote mode, enter your Mac's IP address
4. Start chatting!

## 🔧 Troubleshooting

### macOS
- **"App can't be opened"**: Right-click → Open
- **"App is damaged"**: Run `xattr -cr /Applications/Wisbee.app`

### Windows
- **"Windows protected your PC"**: Click "More info" → "Run anyway"
- **Missing DLL errors**: Install Visual C++ Redistributable

### Linux
- **AppImage won't run**: Install FUSE: `sudo apt install fuse`
- **Missing libraries**: Install: `sudo apt install libgtk-3-0 libnotify4 libnss3`

### iOS
- **Can't connect to Mac**: Ensure both devices are on same network
- **Model download fails**: Check storage space

## 📞 Support

- GitHub Issues: [github.com/enablerdao/wisbee/issues](https://github.com/enablerdao/wisbee/issues)
- Documentation: [wisbee.ai/docs](https://wisbee.ai/docs)
- Community: [Discord](https://discord.gg/wisbee)