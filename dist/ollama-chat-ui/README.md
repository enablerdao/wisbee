# Ollama Chat UI

A modern, sleek web interface for interacting with Ollama models locally. Features real-time streaming responses, conversation context, and a beautiful dark theme.

![Ollama Chat UI](https://img.shields.io/badge/Ollama-Chat%20UI-7c3aed?style=for-the-badge&logo=ai&logoColor=white)

## ✨ Features

- 🎨 **Modern Dark Theme** - Beautiful, eye-friendly interface
- 🚀 **Real-time Streaming** - See responses as they're generated
- 💬 **Conversation Context** - Maintains chat history for contextual responses
- 🎯 **Multiple Models** - Easy switching between different Ollama models
- ⚙️ **Configurable** - Customize models, tokens, temperature via config file
- 📱 **Responsive Design** - Works on desktop and mobile devices
- 🌸 **Japanese Language Support** - Full support for Japanese prompts and responses

## 🚀 Quick Start

### Prerequisites

1. Install [Ollama](https://ollama.ai/) and ensure it's running on `localhost:11434`
2. Pull the models you want to use:
```bash
ollama pull qwen3:latest
ollama pull llama3.2:1b
ollama pull phi3:mini
ollama pull gemma3:4b
ollama pull gemma3:1b
```

3. Python 3.7+ installed

### Installation

1. Clone the repository:
```bash
git clone https://github.com/enablerdao/ollama-chat-ui.git
cd ollama-chat-ui
```

2. Install dependencies:
```bash
pip install requests
```

3. Start the server:
```bash
python3 ollama-webui-server.py
```

4. Open your browser and navigate to `http://localhost:8899`

## 🎛️ Configuration

Edit `config.json` to customize:

```json
{
  "server": {
    "port": 8899,
    "host": "localhost"
  },
  "ollama": {
    "url": "http://localhost:11434",
    "defaultModel": "qwen3:latest",
    "models": [
      "qwen3:latest",
      "llama3.2:1b",
      "phi3:mini",
      "gemma3:4b",
      "gemma3:1b"
    ]
  },
  "ui": {
    "defaultMaxTokens": 2000,
    "defaultTemperature": 0.7,
    "theme": "dark",
    "title": "Ollama AI Chat"
  }
}
```

## 🎯 Usage

### Basic Chat
1. Type your message in the input field
2. Press Enter or click Send
3. Watch the response stream in real-time

### Using Example Prompts
- Click on any prompt in the sidebar to use it
- Categories include: Creative, Logic, Math, Code, and Japanese

### Model Switching
- Use the dropdown in the header to switch between models
- Each model has different capabilities and speeds

### Adjusting Parameters
- **Max Tokens**: Control response length (10-8000)
- **Temperature**: Control creativity (0.0-2.0)
  - Lower = more focused/deterministic
  - Higher = more creative/random

## 🛠️ Custom Deployment

### Running on Different Port
```bash
python3 ollama-webui-server.py 8080
```

### Running with Custom Config
Create your own `config.json` in the project directory.

## 📝 Project Structure

```
ollama-chat-ui/
├── index.html          # Main UI file
├── ollama-webui-server.py  # Python server with CORS proxy
├── config.json         # Configuration file
├── LICENSE            # MIT License
└── README.md          # This file
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Ollama](https://ollama.ai/) for the amazing local LLM runtime
- All the open-source model creators
- The AI community for continuous inspiration

## 🐛 Known Issues

- Large conversations may slow down after many messages (clear chat to reset)
- Some models may not support Japanese well
- Streaming may not work properly with some proxy configurations

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check existing issues for solutions
- Ensure Ollama is running and accessible

---

Made with ❤️ by [EnablerDAO](https://github.com/enablerdao)