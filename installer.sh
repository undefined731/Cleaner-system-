#!/bin/bash

# Define variables
SCRIPT_NAME="cleaner_system.sh"
INSTALL_DIR="/usr/local/bin"
ALIAS_NAME="clean"
ALIAS_COMMAND="sudo $INSTALL_DIR/$SCRIPT_NAME"

# Colors for styling
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Verbose output with styling
info() {
    echo -e "${GREEN}[$1]${RESET} $2"
}

warn() {
    echo -e "${YELLOW}[$1]${RESET} $2"
}

error() {
    echo -e "${RED}[$1]${RESET} $2" >&2
    exit 1
}

# Check if running as root and prompt for sudo if not
if [[ $EUID -ne 0 ]]; then
    info "INFO" "This script requires sudo privileges."
    exec sudo "$0" "$@"
fi

# Verbose output
set -x

# Copy the cleaner script to /usr/local/bin
info "INSTALL" "Installing $SCRIPT_NAME to $INSTALL_DIR..."
if ! sudo cp $SCRIPT_NAME $INSTALL_DIR/; then
    error "ERROR" "Failed to copy $SCRIPT_NAME to $INSTALL_DIR"
fi

if ! sudo chmod +x $INSTALL_DIR/$SCRIPT_NAME; then
    error "ERROR" "Failed to make $SCRIPT_NAME executable"
fi

# Function to add alias on .zshrc or .bashrc
add_alias() {
    local shell_rc=$1
    if [ -f $shell_rc ]; then
        if ! grep -q "alias $ALIAS_NAME=" $shell_rc; then
            info "ADD" "Adding alias to $shell_rc..."
            if ! echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" >> $shell_rc; then
                error "ERROR" "Failed to add alias to $shell_rc"
            fi
        else
            warn "EXIST" "Alias already exists in $shell_rc"
        fi
    else
        warn "CREATE" "$shell_rc does not exist. Creating it..."
        if ! echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" > $shell_rc; then
            error "ERROR" "Failed to create $shell_rc with alias"
        fi
    fi
}

# Add alias to .bashrc and .zshrc
add_alias ~/.bashrc
add_alias ~/.zshrc

# Inform the user to source the updated shell configuration files
info "SOURCE" "Please run 'source ~/.bashrc' or 'source ~/.zshrc' to apply the changes."
info "COMPLETE" "Installation complete. You can now use the 'clean' command."
