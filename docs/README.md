# Cleaner System

Cleaner System is a comprehensive and user-friendly tool designed to help you maintain your Linux system by performing various cleanup tasks. It aims to keep your system running smoothly by freeing up disk space, removing unnecessary files, and optimizing system performance. With a range of features from cleaning caches to removing unused dependencies, Cleaner System is the perfect utility for regular system maintenance.

## Features

- **System Update**: Updates package lists and upgrades installed packages to keep your system up-to-date.
- **Clean Package Cache**: Cleans up the package cache to free up space.
- **Clean Thumbnail Cache**: Removes cached thumbnails older than a specified duration to reclaim disk space.
- **Rotate and Clean Old System Logs**: Manages system logs by rotating and cleaning logs older than a specified duration.
- **Clear Swap (If Not in Use)**: Clears the swap space if it's not actively being used to ensure optimal performance.
- **Remove Unused Dependencies**: Removes packages that are no longer needed by any installed software.
- **Clean Temporary Files**: Deletes temporary files older than a specified duration to free up disk space.
- **Clean Browser Caches**: Cleans cache files from popular browsers (Firefox, Chrome, Brave) that are older than a specified duration.
- **Generate System and Cleaning Reports**: Generates detailed reports summarizing the cleanup actions performed and the current system state.
- **Dry Run Mode**: Allows you to simulate cleanup actions without making any changes to the system.

## Usage

The script provides various options to perform specific cleanup tasks. You can run the script with one or more options as needed.

### Basic Usage

```sh
sudo clean [options]
```
# Options

    -a, --all: Perform all cleaning actions.
    -u, --update: Update package lists and upgrade installed packages.
    -c, --cache: Clean the package cache.
    -t, --thumbnail: Clean thumbnail cache older than 7 days.
    -l, --logs: Rotate and clean old system logs.
    -s, --swap: Clear swap if not in use.
    -T, --tmp: Clean temporary files older than 7 days.
    -b, --browsers: Clean browser caches older than 7 days.
    -r, --report: Generate a cleaning report.
    --dry-run: Simulate actions without making changes.
    -h, --help: Display help information.

# Examples

    Perform All Cleaning Actions
```sh
sudo clean --all
```
**- Clean Package Cache and Generate a Report**
```sh
sudo clean --cache --report
```
**- Simulate Cleaning Temporary Files Without Making Changes**
```sh
sudo clean --tmp --dry-run
```
**- Update System and Clean Unused Dependencies**
```sh
sudo clean --update
sudo clean --remove-unused
```    
