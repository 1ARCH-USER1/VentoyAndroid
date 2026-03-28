#!/bin/bash

# Ventoy Termux Installer
# One-command installer for Ventoy Drive Creator on Termux

set -e

REPO_URL="https://raw.githubusercontent.com/1ARCH-USER1/VentoyAndroid/main"
INSTALL_DIR="$HOME"
SCRIPT_NAME="ventoy-termux.sh"

echo "=========================================="
echo "Ventoy Termux Installer"
echo "=========================================="
echo ""

# Check if running in Termux
if [ -z "$TERMUX_VERSION" ] && [ ! -d "/data/data/com.termux" ]; then
    echo "❌ Error: This installer must be run in Termux on Android"
    exit 1
fi

echo "✅ Termux environment detected"
echo ""

# Update packages
echo "📦 Updating package lists..."
pkg update -y

# Install required dependencies
echo "📦 Installing dependencies..."
pkg install -y \
    curl \
    tar \
    wget \
    busybox \
    file \
    bc

# Optional but recommended packages
echo "📦 Installing optional packages..."
pkg install -y \
    exfat-utils \
    parted \
    e2fsprogs \
    util-linux \
    2>/dev/null || echo "⚠️ Some optional packages failed to install"

# Setup storage permissions
echo ""
echo "🔐 Setting up storage permissions..."
if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
    echo "⏳ Please grant storage permission and press Enter to continue..."
    read
fi

# Download the main script
echo ""
echo "⬇️ Downloading Ventoy Termux script..."

# Try GitHub raw URL first, fallback to local if available
if curl -s --head "$REPO_URL/ventoy-termux.sh" | head -1 | grep -q "200"; then
    curl -L "$REPO_URL/ventoy-termux.sh" -o "$INSTALL_DIR/$SCRIPT_NAME"
else
    echo "⚠️ Could not download from GitHub, checking local files..."
    if [ -f "ventoy-termux.sh" ]; then
        cp "ventoy-termux.sh" "$INSTALL_DIR/"
    else
        echo "❌ Error: Cannot find ventoy-termux.sh"
        exit 1
    fi
fi

# Make executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Create symlink in bin directory
mkdir -p "$HOME/.shortcuts"
ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$HOME/.shortcuts/ventoy"

# Create desktop shortcut if termux-widget is installed
if [ -d "$HOME/.shortcuts" ]; then
    cat > "$HOME/.shortcuts/Ventoy Creator" << 'EOF'
#!/bin/bash
cd $HOME
bash ventoy-termux.sh create
EOF
    chmod +x "$HOME/.shortcuts/Ventoy Creator"
fi

# Add to PATH if not already there
if ! grep -q "ventoy-termux" "$HOME/.bashrc" 2>/dev/null; then
    echo ""
    echo "# Ventoy Termux alias" >> "$HOME/.bashrc"
    echo "alias ventoy='bash $INSTALL_DIR/$SCRIPT_NAME'" >> "$HOME/.bashrc"
fi

echo ""
echo "=========================================="
echo "✅ Installation Complete!"
echo "=========================================="
echo ""
echo "Usage:"
echo "  ventoy-termux.sh create  - Create Ventoy drive"
echo "  ventoy-termux.sh list    - List USB drives"
echo "  ventoy-termux.sh update  - Update Ventoy"
echo "  ventoy-termux.sh copy    - Copy ISO files"
echo "  ventoy-termux.sh help    - Show help"
echo ""
echo "Or use alias:"
echo "  ventoy create"
echo ""
echo "📱 Widget shortcut created (if termux-widget installed)"
echo ""
echo "🔌 Connect USB drive via OTG and run:"
echo "   ventoy-termux.sh create"
echo ""
