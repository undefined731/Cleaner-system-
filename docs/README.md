# Cleaner System

Cleaner System is a comprehensive and user-friendly tool designed to help you maintain your Linux system by performing various cleanup tasks. It aims to keep your system running smoothly by freeing up disk space, removing unnecessary files, and optimizing system performance. With a range of features from cleaning cache to removing old kernels, Cleaner System is the perfect utility for regular system maintenance.

## Features

- **Update System**: Updates package lists and upgrades installed packages.
- **Clean Package Cache**: Cleans up package cache to free up space.
- **Clean Thumbnail Cache**: Removes cached thumbnails to reclaim disk space.
- **Delete Old System Logs**: Deletes old system logs to prevent them from occupying too much space.
- **Clear Swap**: Clears the swap space to ensure optimal performance.
- **Remove Old Kernels**: Removes old and unused kernels to free up space.
- **Remove Unused Dependencies**: Removes packages that are no longer needed.
- **Free Up RAM**: Drops caches to free up RAM and improve system performance.
- **Clean Temporary Files**: Removes temporary files to free up disk space.
- **Clean Browser Caches**: Removes cache files from popular browsers (Firefox, Chrome, Brave).
- **Generate Reports**: Generates a report summarizing the cleanup actions performed and the system state.

## Usage

To use the cleaner script, run it with the appropriate options. Here are some examples:

- Perform all cleaning actions and generate a report:
  ```sh
  sudo ./cleaner_system.sh --all --report

# Compatibility

The current script is designed to work on Debian-based and Ubuntu-based distributions. It may not work correctly on other distributions without modifications. Below is a list of distributions that may require changes to the script for compatibility:

- Fedora: Uses dnf or yum for package management.
- CentOS/RHEL: Uses yum or dnf for package management.
- openSUSE: Uses zypper for package management.
- Arch Linux: Uses pacman for package management.
- NixOS: Has a unique package management system and filesystem structure.
- Gentoo: Uses emerge for package management.
- Void Linux: Uses xbps for package management.
- Slackware: Has different methods for package and system management.
- Clear Linux: Uses swupd for package management.
- Disclaimer
- Please read the documentation carefully. This script can delete important files. Use it at your own risk. - - Always ensure you have backups of your important data before using the cleaner script.

# Reporting Bugs

Report bugs to : acronym4725@protonmail.com