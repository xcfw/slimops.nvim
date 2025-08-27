#!/bin/bash
# LSP Server Installation Script for macOS
# Run this script to install all the LSP servers configured in your Neovim setup

echo "Installing LSP servers..."

# Install Node.js packages globally
echo "Installing Node.js-based LSP servers..."
npm install -g typescript typescript-language-server
npm install -g vscode-langservers-extracted
npm install -g @tailwindcss/language-server

# Install Python LSP
echo "Installing Python LSP server..."
pip install pyright

# Install Go LSP
echo "Installing Go LSP server..."
go install golang.org/x/tools/gopls@latest

# Install Ruby LSP
echo "Installing Ruby LSP server..."
gem install solargraph

# Install Lua LSP (macOS with Homebrew)
echo "Installing Lua LSP server..."
brew install lua-language-server

echo "All LSP servers installed successfully!"
echo "Restart Neovim to use the new configuration."
