!/bin/bash

# Installer Script for Cleaner System
# This script installs the cleaner_system.sh script and sets up an alias for easy use.

# Colors for styling output
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Function to display informational messages
info() {
    echo -e "${GREEN}[$1]${RESET} $2"
}

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
    exit 1
}

# Variables
SCRIPT_NAME="cleaner_system.sh"
SCRIPT_DIR="$(dirname "$(realpath "$0")")/bin"
MAN_PAGE="clean.1"
MAN_PAGE_DIR="$(dirname "$(realpath "$0")")/man"
INSTALL_DIR="/usr/local/bin"
MAN_DIR="/usr/local/share/man/man1"
ALIAS_NAME="clean"
ALIAS_COMMAND="sudo $INSTALL_DIR/$SCRIPT_NAME"

# Check if the script is run as root
if [[ $EUID -eq 0 ]]; then
    error_exit "Please do not run this script as root or with sudo."
fi

# Install the cleaner_system.sh script to /usr/local/bin (requires sudo)
info "INSTALL" "Installing $SCRIPT_NAME to $INSTALL_DIR..."
sudo cp "$SCRIPT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/" || error_exit "Failed to copy $SCRIPT_NAME to $INSTALL_DIR"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME" || error_exit "Failed to make $SCRIPT_NAME executable"

# Install the man page (requires sudo)
info "INSTALL" "Installing $MAN_PAGE to $MAN_DIR..."
sudo mkdir -p "$MAN_DIR" || error_exit "Failed to create directory $MAN_DIR"
sudo cp "$MAN_PAGE_DIR/$MAN_PAGE" "$MAN_DIR/" || error_exit "Failed to copy $MAN_PAGE to $MAN_DIR"
sudo gzip -f "$MAN_DIR/$MAN_PAGE" || error_exit "Failed to compress $MAN_PAGE"

# Detect the user's shell
USER_SHELL="$(basename "$SHELL")"
USER_RC_FILE="$HOME/.${USER_SHELL}rc"

# Function to add alias to the shell configuration file
add_alias() {
    local shell_rc=$1
    if [ -f "$shell_rc" ]; then
        # Check if the alias already exists
        if ! grep -Fxq "alias $ALIAS_NAME='$ALIAS_COMMAND'" "$shell_rc"; then
            info "ALIAS" "Adding alias to $shell_rc..."
            echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" >> "$shell_rc" || error_exit "Failed to add alias to $shell_rc"
        else
            info "ALIAS" "Alias already exists in $shell_rc."
        fi
    else
        info "CREATE" "$shell_rc does not exist. Creating the file and adding alias..."
        echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" > "$shell_rc" || error_exit "Failed to create $shell_rc with alias"
    fi

    # Inform the user to reload their shell configuration
    info "SOURCE" "Please run 'source $shell_rc' or restart your terminal for the alias to take effect."
}

# Add the alias
add_alias "$USER_RC_FILE"

# Success message
info "SUCCESS" "Alias '$ALIAS_NAME' added successfully to $USER_RC_FILE."
info "COMPLETE" "Installation complete. You can now use the '$ALIAS_NAME' command."
info "MANUAL" "You can view the manual page using 'man $ALIAS_NAME'."