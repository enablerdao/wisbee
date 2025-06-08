# Ollama Chat for Mac - Release v1.0.0

## 🎉 Initial Release

Ollama Chat is now available as a native macOS application! Run your local LLMs with a beautiful, native interface.

### ✨ Features

- 🎨 **Native macOS Experience** - Beautiful dark theme with native window controls
- 🚀 **Real-time Streaming** - See AI responses as they're generated
- 💬 **Conversation Context** - Maintains chat history for contextual responses
- 🎯 **Multiple Models** - Easy switching between different Ollama models
- ⚙️ **Configurable Settings** - Adjust tokens, temperature, and more
- 🌸 **Japanese Language Support** - Full support for Japanese prompts and responses
- 📱 **Universal Binary** - Native support for both Intel and Apple Silicon Macs

### 📥 Downloads

- **Intel Mac**: [Ollama Chat-1.0.0.dmg](https://github.com/enablerdao/ollama-chat-ui/releases/download/v1.0.0/Ollama.Chat-1.0.0.dmg) (100.6 MB)
- **Apple Silicon (M1/M2/M3)**: [Ollama Chat-1.0.0-arm64.dmg](https://github.com/enablerdao/ollama-chat-ui/releases/download/v1.0.0/Ollama.Chat-1.0.0-arm64.dmg) (94.1 MB)

### 🚀 Installation

1. Download the appropriate DMG file for your Mac
2. Open the downloaded DMG file
3. Drag "Ollama Chat" to your Applications folder
4. **Important for first launch**: Since the app is not notarized yet, you'll need to:
   - Right-click (or Control-click) on the app in Applications
   - Select "Open" from the context menu
   - Click "Open" in the security dialog
   - After the first launch, you can open it normally

### 📋 Requirements

- macOS 10.12 or later
- [Ollama](https://ollama.ai/) installed and running on `localhost:11434`
- Python 3.7+ (included in macOS)

### 🐛 Known Issues

- App is not notarized yet (working on Apple Developer enrollment)
- First launch requires manual approval (see installation instructions)
- Large conversations may slow down after many messages (clear chat to reset)

### 🛠️ Troubleshooting

If the app doesn't connect to Ollama:
1. Ensure Ollama is running: `ollama serve`
2. Check that models are installed: `ollama list`
3. Try restarting the app

### 🤝 Contributing

This is an open-source project! Contributions are welcome:
- Report issues on [GitHub](https://github.com/enablerdao/ollama-chat-ui/issues)
- Submit pull requests for improvements
- Share feedback and feature requests

### 📄 License

MIT License - see [LICENSE](https://github.com/enablerdao/ollama-chat-ui/blob/main/LICENSE) for details

---

Made with ❤️ by [EnablerDAO](https://github.com/enablerdao)