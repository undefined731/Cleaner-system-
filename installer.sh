#!/bin/bash

# Variables
SCRIPT_NAME="cleaner_system.sh"
SCRIPT_DIR="$(dirname "$(realpath "$0")")/bin"
INSTALL_DIR="/usr/local/bin"
MAN_DIR="/usr/local/share/man/man1"
ALIAS_NAME="cleanmaster"
ALIAS_COMMAND="sudo $INSTALL_DIR/$SCRIPT_NAME"
MAN_PAGE="clean.1"
MAN_PAGE_DIR="$(dirname "$(realpath "$0")")/man"

# Colors for styling
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Verbose output with styling
info() {
    echo -e "${GREEN}[$1]${RESET} $2"
}

error() {
    echo -e "${RED}[$1]${RESET} $2"
    exit 1
}

# Check if running as root and prompt for sudo if not
if [[ $EUID -ne 0 ]]; then
    info "INFO" "This script requires sudo privileges."
    exec sudo "$0" "$@"
fi

# Verbose output
set -x

# Create the local bin directory if it does not exist
if [ ! -d "$INSTALL_DIR" ]; then
    info "CREATE" "Creating directory $INSTALL_DIR..."
    mkdir -p $INSTALL_DIR || error "ERROR" "Failed to create directory $INSTALL_DIR"
fi

# Copy the cleaner script to /usr/local/bin
info "INSTALL" "Installing $SCRIPT_NAME to $INSTALL_DIR..."
cp "$SCRIPT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/" || error "ERROR" "Failed to copy $SCRIPT_NAME to $INSTALL_DIR"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME" || error "ERROR" "Failed to make $SCRIPT_NAME executable"

# Create the man directory if it does not exist
if [ ! -d "$MAN_DIR" ]; then
    info "CREATE" "Creating directory $MAN_DIR..."
    sudo mkdir -p $MAN_DIR || error "ERROR" "Failed to create directory $MAN_DIR"
fi

# Copy the man page to /usr/local/share/man/man1
info "INSTALL" "Installing $MAN_PAGE to $MAN_DIR..."
sudo cp "$MAN_PAGE_DIR/$MAN_PAGE" "$MAN_DIR/" || error "ERROR" "Failed to copy $MAN_PAGE to $MAN_DIR"
sudo gzip -f "$MAN_DIR/$MAN_PAGE" || error "ERROR" "Failed to compress $MAN_PAGE"

# Function to add alias
add_alias() {
    local shell_rc=$1
    if [ -f $shell_rc ]; then
        if ! grep -q "alias $ALIAS_NAME=" $shell_rc; then
            info "ADD" "Adding alias to $shell_rc..."
            echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" >> $shell_rc || error "ERROR" "Failed to add alias to $shell_rc"
        else
            info "EXIST" "Alias already exists in $shell_rc"
        fi
    else
        info "CREATE" "$shell_rc does not exist. Creating it..."
        echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" > $shell_rc || error "ERROR" "Failed to create $shell_rc with alias"
    fi
}

# Add alias to .bashrc and .zshrc
add_alias ~/.bashrc
add_alias ~/.zshrc

# Inform the user to source the updated shell configuration files
info "SOURCE" "Please run 'source ~/.bashrc' or 'source ~/.zshrc' to apply the changes."
info "COMPLETE" "Installation complete. You can now use the 'cleanmaster' command."
info "MANUAL" "You can now view the manual using 'man clean'."
