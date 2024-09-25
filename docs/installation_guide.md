# Installation
## Prerequisites

- A Debian-based or Ubuntu-based Linux distribution.
- sudo privileges.

# Steps

1. Download the Repository

Clone the repository to your local machine:

```sh
git clone https://github.com/yourusername/cleaner-system.git
```
2. Navigate to the Repository Directory
```sh
cd cleaner_system
```
3. Run the Installer Script

Run the installer script without sudo:
```sh
./installer.sh
```
The script will prompt you for your password when necessary for sudo commands.

Source Your Shell Configuration File

After installation, reload your shell configuration for the clean alias to take effect.

- For Bash Users:

```sh
source ~/.bashrc
```
- For Zsh Users:

```sh

source ~/.zshrc
```
# Verify the Installation

You can now use the clean command:

```sh
clean --help
```
# Compatibility

The script is designed to work on Debian-based and Ubuntu-based distributions. It may not work correctly on other distributions without modifications.
Distributions That May Require Modifications

  - Fedora: Uses dnf or yum for package management.
  - CentOS/RHEL: Uses yum or dnf for package management.
  - openSUSE: Uses zypper for package management.
  - Arch Linux: Uses pacman for package management.
  - Others: Adjustments may be needed for other distributions with different package managers or filesystem structures.

# Disclaimer

Please read the documentation carefully. This script performs actions that can affect system files. Use it at your own risk. Always ensure you have backups of your important data before using the cleaner script.
Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.
Reporting Bugs

If you encounter any bugs or issues, please report them by opening an issue on the GitHub repository or contact:

Email: acronym4725@protonmail.com