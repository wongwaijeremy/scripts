#!/bin/bash

# ==========================================
# SERVER SETUP SCRIPT (Ubuntu/Debian)
# ==========================================
# Installs:
# 1. Essential Utils (git, tmux, zsh, eza)
# 2. Neovim (Latest Stable) via tarball
# 3. NvChad (Neovim Config)
# ==========================================

set -e # Exit immediately if a command exits with a non-zero status

echo "--- [1/6] Updating System & Installing Essentials ---"
sudo apt update
sudo apt install git tmux eza unzip build-essential -y

echo "--- [2/6] Detecting Architecture ---"
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    NVIM_ARCH="linux64"
    POSH_ARCH="amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    NVIM_ARCH="linux-arm64"
    POSH_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
echo "Detected: $ARCH"

echo "--- [3/6] Installing Neovim (Latest Stable) ---"
# Remove old apt version if it exists
sudo apt remove -y neovim neovim-runtime 2>/dev/null || true

# Download and Install
curl -LO "https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-$ARCH.appimage"
chmod u+x nvim-linux-$ARCH.appimage
sudo mv nvim-linux-$ARCH.appimage /usr/local/bin/nvim


echo "--- [4/6] Installing NvChad ---"
# Backup existing neovim config if present
if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
    echo "Backed up existing nvim config."
fi
if [ -d "$HOME/.local/share/nvim" ]; then
    mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak.$(date +%s)"
fi

# Clone NvChad
git clone https://github.com/NvChad/Starter "$HOME/.config/nvim" 

echo "--- [5/6] Installing Oh My Posh ---"
curl -s https://ohmyposh.dev/install.sh | bash -s
curl -o "$HOME/.config/EDM115-newline.omp.json" https://raw.githubusercontent.com/wongwaijeremy/scripts/master/EDM115-newline.omp.json

echo "--- [6/6] Configuring .bashrc ---"
cat <<EOF > "$HOME/.profile"

# Aliases
alias ls = 'eza -a --icons=always'
alias ll = 'eza -la --icons=always'
alias lt = 'eza -a --tree --level=1 --icons=always'
alias v = '$EDITOR'

# Oh My Posh Initialization
eval "$(oh-my-posh init bash --config $HOME/.config/EDM115-newline.omp.json)"
EOF

source "$HOME/.profile"
echo "=========================================="
echo "Setup Complete! "
echo "1. IMPORTANT: Please install a 'Nerd Font' on your LOCAL terminal to see icons correctly."
echo "2. Run 'nvim' to finish NvChad installation (it will install plugins on first launch)."
echo "=========================================="
