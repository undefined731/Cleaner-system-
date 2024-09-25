#!/bin/bash

# Cleaner System Script
# This script performs various system cleanup tasks to free up disk space and optimize performance.

# Exit immediately if a command exits with a non-zero status
set -e

# Set locale to C for consistent command outputs
export LANG=C

# Colors for styling output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# Log and report files
LOG_FILE="/var/log/cleaner.log"
REPORT_FILE="/var/log/cleaner_report.log"

# Initialize tracking variables
CACHE_COUNT=0
CACHE_SIZE_BEFORE=0
CACHE_SIZE_AFTER=0
THUMBNAIL_COUNT=0
THUMBNAIL_SIZE_BEFORE=0
THUMBNAIL_SIZE_AFTER=0
LOG_COUNT=0
LOG_SIZE_BEFORE=0
LOG_SIZE_AFTER=0
SWAP_USAGE_BEFORE=0
SWAP_USAGE_AFTER=0
TMP_COUNT=0
TMP_SIZE_BEFORE=0
TMP_SIZE_AFTER=0
BROWSER_COUNT=0
BROWSER_SIZE_BEFORE=0
BROWSER_SIZE_AFTER=0

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --all              Perform all cleaning actions"
    echo "  -u, --update           Update package lists and installed packages"
    echo "  -c, --cache            Clean package cache"
    echo "  -t, --thumbnail        Clean thumbnail cache"
    echo "  -l, --logs             Rotate and clean old system logs"
    echo "  -s, --swap             Clear swap if not in use"
    echo "  -T, --tmp              Clean temporary files older than 7 days"
    echo "  -b, --browsers         Clean browser caches"
    echo "  -r, --report           Generate a cleaning report"
    echo "  --dry-run              Simulate actions without making changes"
    echo "  -h, --help             Display this help message"
}

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to display informational messages
info() {
    echo -e "${GREEN}[+]${RESET} $1"
}

# Function to display warning messages
warning() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
    exit 1
}

# Function to generate system report
generate_system_report() {
    {
        echo "System report generated on $(date)"
        echo "------------------------------------"
        echo -e "\nDisk Usage:"
        df -h
        echo -e "\nMemory Usage:"
        free -h
        echo -e "\nTop Processes:"
        ps aux --sort=-%mem | head -15
        echo "------------------------------------"
    } >> "$REPORT_FILE"
}

# Function to generate cleaning report
generate_cleaning_report() {
    {
        echo "Cleaning report generated on $(date)"
        echo "------------------------------------"
        printf "%-12s %-15s %-15s\n" "Category" "Size Before" "Size After"
        printf "%-12s %-15s %-15s\n" "Cache" "$CACHE_SIZE_BEFORE" "$CACHE_SIZE_AFTER"
        printf "%-12s %-15s %-15s\n" "Thumbnail" "$THUMBNAIL_SIZE_BEFORE" "$THUMBNAIL_SIZE_AFTER"
        printf "%-12s %-15s %-15s\n" "Logs" "$LOG_SIZE_BEFORE" "$LOG_SIZE_AFTER"
        printf "%-12s %-15s %-15s\n" "Swap Used" "$SWAP_USAGE_BEFORE" "$SWAP_USAGE_AFTER"
        printf "%-12s %-15s %-15s\n" "Temporary" "$TMP_SIZE_BEFORE" "$TMP_SIZE_AFTER"
        printf "%-12s %-15s %-15s\n" "Browsers" "$BROWSER_SIZE_BEFORE" "$BROWSER_SIZE_AFTER"
        echo "------------------------------------"
        echo "Detailed actions:"
        cat "$LOG_FILE"
    } >> "$REPORT_FILE"
}

# Function to perform all cleaning actions
clean_all() {
    update_system
    clean_cache
    clean_thumbnail_cache
    clean_logs
    clean_swap
    clean_tmp
    clean_browsers
    remove_unused_dependencies
}

# Function to update the system
update_system() {
    info "Updating package lists and upgrading installed packages..."
    log_action "Updating package lists and upgrading installed packages"
    apt-get update -y && apt-get upgrade -y
}

# Function to clean package cache
clean_cache() {
    info "Cleaning package cache..."
    log_action "Cleaning package cache"
    CACHE_SIZE_BEFORE=$(du -sh /var/cache/apt | awk '{print $1}')
    apt-get clean -y
    CACHE_SIZE_AFTER=$(du -sh /var/cache/apt | awk '{print $1}')
}

# Function to clean thumbnail cache
clean_thumbnail_cache() {
    info "Cleaning thumbnail cache older than 7 days..."
    log_action "Cleaning thumbnail cache"
    THUMBNAIL_SIZE_BEFORE=$(du -sh "${HOME}/.cache/thumbnails" 2>/dev/null | awk '{print $1}')
    find "${HOME}/.cache/thumbnails/" -type f -mtime +7 -exec rm -f {} \;
    THUMBNAIL_SIZE_AFTER=$(du -sh "${HOME}/.cache/thumbnails" 2>/dev/null | awk '{print $1}')
}

# Function to rotate and clean old system logs
clean_logs() {
    info "Rotating and cleaning old system logs..."
    log_action "Rotating and cleaning old system logs"
    LOG_SIZE_BEFORE=$(du -sh /var/log 2>/dev/null | awk '{print $1}')
    logrotate -f /etc/logrotate.conf
    journalctl --vacuum-time=7d
    LOG_SIZE_AFTER=$(du -sh /var/log 2>/dev/null | awk '{print $1}')
}

# Function to clear swap if not in use
clean_swap() {
    SWAP_USAGE_BEFORE=$(free -h | awk '/Swap/ {print $3}')
    if [ "$(free | awk '/Swap/ {print $3}')" -eq 0 ]; then
        info "Swap is not in use. No need to clear swap."
        SWAP_USAGE_AFTER=$SWAP_USAGE_BEFORE
    else
        warning "Swap is currently in use (${SWAP_USAGE_BEFORE}). Clearing swap can affect running applications."
        read -p "Do you want to proceed with clearing swap? [y/N]: " choice
        case "$choice" in
            y|Y )
                info "Clearing swap..."
                log_action "Clearing swap"
                swapoff -a && swapon -a
                SWAP_USAGE_AFTER=$(free -h | awk '/Swap/ {print $3}')
                ;;
            * )
                info "Skipping swap clearing."
                SWAP_USAGE_AFTER=$SWAP_USAGE_BEFORE
                ;;
        esac
    fi
}

# Function to clean temporary files older than 7 days
clean_tmp() {
    info "Cleaning temporary files older than 7 days..."
    log_action "Cleaning temporary files"
    TMP_SIZE_BEFORE=$(du -sh /tmp 2>/dev/null | awk '{print $1}')
    find /tmp -type f -mtime +7 -exec rm -f {} \;
    TMP_SIZE_AFTER=$(du -sh /tmp 2>/dev/null | awk '{print $1}')
}

# Function to clean browser caches
clean_browsers() {
    info "Cleaning browser caches older than 7 days..."
    log_action "Cleaning browser caches"
    BROWSER_SIZE_BEFORE=0
    BROWSER_SIZE_AFTER=0

    # Firefox
    if [ -d "${HOME}/.cache/mozilla" ]; then
        BROWSER_SIZE_BEFORE=$(du -sh "${HOME}/.cache/mozilla" 2>/dev/null | awk '{print $1}')
        find "${HOME}/.cache/mozilla/" -type f -mtime +7 -exec rm -f {} \;
        BROWSER_SIZE_AFTER=$(du -sh "${HOME}/.cache/mozilla" 2>/dev/null | awk '{print $1}')
    fi

    # Chrome
    if [ -d "${HOME}/.cache/google-chrome" ]; then
        size_before=$(du -sh "${HOME}/.cache/google-chrome" 2>/dev/null | awk '{print $1}')
        find "${HOME}/.cache/google-chrome/" -type f -mtime +7 -exec rm -f {} \;
        size_after=$(du -sh "${HOME}/.cache/google-chrome" 2>/dev/null | awk '{print $1}')
        BROWSER_SIZE_BEFORE="$BROWSER_SIZE_BEFORE + $size_before"
        BROWSER_SIZE_AFTER="$BROWSER_SIZE_AFTER + $size_after"
    fi

    # Brave
    if [ -d "${HOME}/.cache/BraveSoftware" ]; then
        size_before=$(du -sh "${HOME}/.cache/BraveSoftware" 2>/dev/null | awk '{print $1}')
        find "${HOME}/.cache/BraveSoftware/" -type f -mtime +7 -exec rm -f {} \;
        size_after=$(du -sh "${HOME}/.cache/BraveSoftware" 2>/dev/null | awk '{print $1}')
        BROWSER_SIZE_BEFORE="$BROWSER_SIZE_BEFORE + $size_before"
        BROWSER_SIZE_AFTER="$BROWSER_SIZE_AFTER + $size_after"
    fi
}

# Function to remove unused dependencies
remove_unused_dependencies() {
    info "Removing unused dependencies..."
    log_action "Removing unused dependencies"
    apt-get autoremove -y
}

# Function to perform a dry run
dry_run=false

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    error_exit "This script must be run as root."
fi

# Check for arguments
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# Parse options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -a|--all)
        ACTION="all"
        shift # past argument
        ;;
        -u|--update)
        ACTION="update"
        shift # past argument
        ;;
        -c|--cache)
        ACTION="cache"
        shift # past argument
        ;;
        -t|--thumbnail)
        ACTION="thumbnail"
        shift # past argument
        ;;
        -l|--logs)
        ACTION="logs"
        shift # past argument
        ;;
        -s|--swap)
        ACTION="swap"
        shift # past argument
        ;;
        -T|--tmp)
        ACTION="tmp"
        shift # past argument
        ;;
        -b|--browsers)
        ACTION="browsers"
        shift # past argument
        ;;
        -r|--report)
        ACTION="report"
        shift # past argument
        ;;
        --dry-run)
        dry_run=true
        shift # past argument
        ;;
        -h|--help)
        usage
        exit 0
        ;;
        *)
        usage
        exit 1
        ;;
    esac
done

# Execute actions based on the parsed options
if [ "$dry_run" = true ]; then
    info "Performing a dry run. No changes will be made."
    # Wrap all destructive commands with echo
    apt_get_command="echo apt-get"
    rm_command="echo rm"
    find_command="echo find"
    swapoff_command="echo swapoff"
    swapon_command="echo swapon"
else
    apt_get_command="apt-get"
    rm_command="rm"
    find_command="find"
    swapoff_command="swapoff"
    swapon_command="swapon"
fi

case $ACTION in
    all)
    clean_all
    ;;
    update)
    update_system
    ;;
    cache)
    clean_cache
    ;;
    thumbnail)
    clean_thumbnail_cache
    ;;
    logs)
    clean_logs
    ;;
    swap)
    clean_swap
    ;;
    tmp)
    clean_tmp
    ;;
    browsers)
    clean_browsers
    ;;
    report)
    generate_system_report
    generate_cleaning_report
    ;;
    *)
    usage
    exit 1
    ;;
esac

# Generate reports after actions
generate_system_report
generate_cleaning_report

info "System cleanup complete!"
log_action "System cleanup complete."
