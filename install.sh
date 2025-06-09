#!/bin/bash

# 🐝 Wisbee CLI Installer
# Universal installer for bee command-line chat interface
# Supports: macOS, Linux, WSL, and various shell environments

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🐝 Wisbee CLI Installer${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE=Linux;;
    Darwin*)    OS_TYPE=Mac;;
    CYGWIN*|MINGW*|MSYS*) OS_TYPE=Windows;;
    *)          OS_TYPE="UNKNOWN:${OS}"
esac

echo "💻 Detected OS: ${OS_TYPE}"

# Detect shell
SHELL_TYPE="unknown"
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
    SHELL_RC="$HOME/.bashrc"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
    SHELL_RC="$HOME/.config/fish/config.fish"
else
    SHELL_RC="$HOME/.profile"
fi

echo "🐚 Detected shell: ${SHELL_TYPE}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Determine installation directory
INSTALL_DIR=""

# Try common directories in order
if [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -d "$HOME/.local/bin" ]; then
    INSTALL_DIR="$HOME/.local/bin"
elif [ -d "$HOME/bin" ]; then
    INSTALL_DIR="$HOME/bin"
elif [ -d "/opt/homebrew/bin" ] && [ -w "/opt/homebrew/bin" ]; then
    INSTALL_DIR="/opt/homebrew/bin"
else
    # Create .local/bin if it doesn't exist
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR" || {
        echo -e "${RED}❌ Error: Cannot create installation directory${NC}"
        echo "Please run with sudo or create $HOME/.local/bin manually"
        exit 1
    }
fi

echo "📍 Installing to: $INSTALL_DIR"


# Install bee commands
echo "📦 Installing bee commands..."

# Download bee and bee-chat if not present
if [ ! -f "bee" ]; then
    echo "📥 Downloading bee..."
    curl -fsSL https://raw.githubusercontent.com/enablerdao/wisbee/main/bee -o bee || \
    wget -q https://raw.githubusercontent.com/enablerdao/wisbee/main/bee -O bee || {
        echo -e "${RED}❌ Error: Failed to download bee${NC}"
        exit 1
    }
fi

if [ ! -f "bee-chat" ]; then
    echo "📥 Downloading bee-chat..."
    curl -fsSL https://raw.githubusercontent.com/enablerdao/wisbee/main/bee-chat -o bee-chat || \
    wget -q https://raw.githubusercontent.com/enablerdao/wisbee/main/bee-chat -O bee-chat || {
        echo -e "${RED}❌ Error: Failed to download bee-chat${NC}"
        exit 1
    }
fi

# Install both scripts
cp bee "$INSTALL_DIR/bee"
cp bee-chat "$INSTALL_DIR/bee-chat"
chmod +x "$INSTALL_DIR/bee" "$INSTALL_DIR/bee-chat"

# Create wisbee alias
echo "🔗 Creating wisbee alias..."
cat > "$INSTALL_DIR/wisbee" << 'EOF'
#!/bin/bash
exec "$(dirname "$0")/bee" "$@"
EOF
chmod +x "$INSTALL_DIR/wisbee"

# Check Python3
echo "🐍 Checking Python..."
if ! command_exists python3; then
    echo -e "${RED}❌ Error: Python 3 is required but not installed${NC}"
    echo "Please install Python 3:"
    case "${OS_TYPE}" in
        Mac)
            echo "  brew install python3"
            ;;
        Linux)
            echo "  sudo apt-get install python3 python3-pip  # Debian/Ubuntu"
            echo "  sudo yum install python3 python3-pip      # RedHat/CentOS"
            ;;
        *)
            echo "  Please install Python 3 for your system"
            ;;
    esac
    exit 1
fi

# Check Python dependencies
echo "📦 Checking Python dependencies..."
python3 -c "import requests" 2>/dev/null || {
    echo "📦 Installing requests library..."
    
    # Try different pip commands
    if command_exists pip3; then
        pip3 install requests --user 2>/dev/null || pip3 install requests
    elif command_exists python3 -m pip; then
        python3 -m pip install requests --user 2>/dev/null || python3 -m pip install requests
    else
        echo -e "${YELLOW}⚠️  Warning: pip not found. You may need to install requests manually:${NC}"
        echo "  python3 -m pip install requests"
    fi
}

# Update PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  $INSTALL_DIR is not in your PATH${NC}"
    
    echo "📝 Adding to $SHELL_RC..."
    
    # Add PATH based on shell type
    case "${SHELL_TYPE}" in
        fish)
            echo "" >> "$SHELL_RC"
            echo "# Wisbee CLI" >> "$SHELL_RC"
            echo "set -gx PATH $INSTALL_DIR \$PATH" >> "$SHELL_RC"
            ;;
        *)
            echo "" >> "$SHELL_RC"
            echo "# Wisbee CLI" >> "$SHELL_RC"
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
            ;;
    esac
    
    echo -e "${GREEN}✅ PATH updated${NC}"
    NEED_SOURCE=true
fi

# Create uninstall script
echo "🗑️  Creating uninstall script..."
cat > "$INSTALL_DIR/uninstall-bee" << EOF
#!/bin/bash
echo "🐝 Uninstalling Wisbee CLI..."
rm -f "$INSTALL_DIR/bee" "$INSTALL_DIR/wisbee" "$INSTALL_DIR/uninstall-bee"
echo "✅ Wisbee CLI uninstalled"
echo "Note: You may want to remove the PATH entry from $SHELL_RC"
EOF
chmod +x "$INSTALL_DIR/uninstall-bee"

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Usage:"
echo "   bee         - Start chat interface"
echo "   bee --help  - Show help"
echo "   wisbee      - Alternative command"
echo ""

if [ "${NEED_SOURCE}" = "true" ]; then
    echo -e "${YELLOW}⚠️  To use bee command, run:${NC}"
    echo -e "   ${GREEN}source $SHELL_RC${NC}"
    echo ""
fi

# Check if Ollama is installed
if command_exists ollama; then
    echo -e "${GREEN}✅ Ollama detected${NC}"
else
    echo -e "${YELLOW}💡 Ollama not found. Install it:${NC}"
    case "${OS_TYPE}" in
        Mac)
            echo "   brew install ollama"
            echo "   or download from: https://ollama.ai/download"
            ;;
        Linux)
            echo "   curl -fsSL https://ollama.ai/install.sh | sh"
            ;;
        *)
            echo "   Visit: https://ollama.ai/download"
            ;;
    esac
fi

echo ""
echo "📖 Next steps:"
echo "   1. Start Ollama: ollama serve"
echo "   2. Pull a model: ollama pull llama3.2"
echo "   3. Start chatting: bee"
echo ""
echo "🗑️  To uninstall: uninstall-bee"
echo ""