# Ollama Chat for Mac

A native macOS application for Ollama Chat UI, providing a seamless desktop experience for interacting with local LLMs.

## 📥 Downloads

- **Intel Mac**: [Ollama Chat-1.0.0.dmg](https://github.com/enablerdao/ollama-chat-ui/releases/download/v1.0.0-mac/Ollama.Chat-1.0.0.dmg) (100.6 MB)
- **Apple Silicon (M1/M2/M3)**: [Ollama Chat-1.0.0-arm64.dmg](https://github.com/enablerdao/ollama-chat-ui/releases/download/v1.0.0-mac/Ollama.Chat-1.0.0-arm64.dmg) (94.1 MB)

## ⚠️ 重要：初回起動について

このアプリは現在署名されていないため、初回起動時に以下の手順が必要です：

1. アプリケーションフォルダで「Ollama Chat」を**右クリック**
2. 「開く」を選択
3. 警告ダイアログで「開く」をクリック

詳細は[インストールガイド](INSTALL_GUIDE.md)を参照してください。

## Features

- 🎨 Beautiful native macOS interface
- 🚀 Real-time streaming responses
- 💬 Conversation context management
- 🎯 Easy model switching
- ⚙️ Configurable settings
- 🌸 Full Japanese language support

## Installation

1. Download the appropriate DMG file for your Mac
2. Open the DMG file
3. Drag "Ollama Chat" to your Applications folder
4. Launch from Applications

## Requirements

- macOS 10.12 or later
- Ollama installed and running on localhost:11434
- Python 3.7+ (for the embedded server)

## Development

To build from source:

```bash
npm install
npm run dist-mac
```

## License

MIT License - see LICENSE file for details