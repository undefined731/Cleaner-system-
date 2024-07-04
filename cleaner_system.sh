#!/bin/bash

echo -e "${RED}Starting system cleanup... Please do not interrupt the process.${RESET}"
echo "
  ____ _     _____    _    _   _   ______   ______ _____ _____ __  __ 
 / ___| |   | ____|  / \  | \ | | / ___\ \ / / ___|_   _| ____|  \/  |
| |   | |   |  _|   / _ \ |  \| | \___ \\ V /\___ \ | | |  _| | |\/| |
| |___| |___| |___ / ___ \| |\  |  ___) || |  ___) || | | |___| |  | |
 \____|_____|_____/_/   \_\_| \_| |____/ |_| |____/ |_| |_____|_|  |_|
                                                                      
"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Variables
LOG_FILE="/var/log/cleaner.log"
REPORT_FILE="/var/log/cleaner_report.log"

# Tracking variables
CACHE_COUNT=0
CACHE_SIZE_BEFORE=0
CACHE_SIZE_AFTER=0
THUMBNAIL_COUNT=0
THUMBNAIL_SIZE_BEFORE=0
THUMBNAIL_SIZE_AFTER=0
LOG_COUNT=0
LOG_SIZE_BEFORE=0
LOG_SIZE_AFTER=0
SWAP_CLEARED=0
TMP_COUNT=0
TMP_SIZE_BEFORE=0
TMP_SIZE_AFTER=0
BROWSER_COUNT=0
BROWSER_SIZE_BEFORE=0
BROWSER_SIZE_AFTER=0
BRAVE_COUNT=0
BRAVE_SIZE_BEFORE=0
BRAVE_SIZE_AFTER=0

# Colors for styling
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Functions
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --all              Perform all cleaning actions"
    echo "  -u, --update           Update package lists and installed packages"
    echo "  -c, --cache            Clean up package cache"
    echo "  -t, --thumbnail        Clean up thumbnail cache"
    echo "  -l, --logs             Delete old system logs"
    echo "  -s, --swap             Clear swap"
    echo "  -T, --tmp              Clean up temporary files"
    echo "  -b, --browsers         Clean browser caches"
    echo "  -B, --brave            Clean Brave browser cache"
    echo "  -r, --report           Generate a cleaning report"
    echo "  -h, --help             Display this help message"
}

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

info() {
    echo -e "${GREEN}[+]${RESET} $1"
}

generate_system_report() {
    echo "System report generated on $(date)" >> $REPORT_FILE
    echo "------------------------------------" >> $REPORT_FILE
    echo -e "\nDisk Usage:" >> $REPORT_FILE
    df -h >> $REPORT_FILE
    echo -e "\nMemory Usage:" >> $REPORT_FILE
    free -h >> $REPORT_FILE
    echo -e "\nTop Processes:" >> $REPORT_FILE
    top -b -n 1 | head -15 >> $REPORT_FILE
    echo "------------------------------------" >> $REPORT_FILE
}

generate_cleaning_report() {
    echo "Cleaning report generated on $(date)" >> $REPORT_FILE
    echo "------------------------------------" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Category" "Count" "Size Before" "Size After" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Cache" "$CACHE_COUNT" "$CACHE_SIZE_BEFORE" "$CACHE_SIZE_AFTER" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Thumbnail" "$THUMBNAIL_COUNT" "$THUMBNAIL_SIZE_BEFORE" "$THUMBNAIL_SIZE_AFTER" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Logs" "$LOG_COUNT" "$LOG_SIZE_BEFORE" "$LOG_SIZE_AFTER" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Swap" "-" "-" "$SWAP_CLEARED" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Temporary" "$TMP_COUNT" "$TMP_SIZE_BEFORE" "$TMP_SIZE_AFTER" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Browsers" "$BROWSER_COUNT" "$BROWSER_SIZE_BEFORE" "$BROWSER_SIZE_AFTER" >> $REPORT_FILE
    printf "%-12s %-10s %-15s %-15s\n" "Brave" "$BRAVE_COUNT" "$BRAVE_SIZE_BEFORE" "$BRAVE_SIZE_AFTER" >> $REPORT_FILE
    echo "------------------------------------" >> $REPORT_FILE
    cat $LOG_FILE >> $REPORT_FILE
}

clean_all() {
    update_system
    clean_cache
    clean_thumbnail_cache
    clean_logs
    clean_swap
    clean_tmp
    clean_browsers
    clean_brave_cache
    remove_old_kernels
    remove_unused_dependencies
    free_up_ram
}

update_system() {
    info "Updating package lists and upgrading installed packages..."
    log_action "Updating package lists and upgrading installed packages"
    sudo apt-get update -y
    sudo apt-get upgrade -y
}

clean_cache() {
    info "Cleaning up package cache..."
    log_action "Cleaning up package cache"
    CACHE_SIZE_BEFORE=$(sudo du -sh /var/cache/apt | awk '{print $1}')
    sudo apt-get clean -y
    sudo apt-get autoclean -y
    CACHE_SIZE_AFTER=$(sudo du -sh /var/cache/apt | awk '{print $1}')
    CACHE_COUNT=$(sudo find /var/cache/apt -type f | wc -l)
}

clean_thumbnail_cache() {
    info "Clearing thumbnail cache..."
    log_action "Clearing thumbnail cache"
    THUMBNAIL_COUNT=$(find ~/.cache/thumbnails/* -type f | wc -l)
    THUMBNAIL_SIZE_BEFORE=$(du -sh ~/.cache/thumbnails/ | awk '{print $1}')
    rm -rfv ~/.cache/thumbnails/* >> $LOG_FILE
    THUMBNAIL_SIZE_AFTER=$(du -sh ~/.cache/thumbnails/ | awk '{print $1}')
}

clean_logs() {
    info "Deleting old system logs..."
    log_action "Deleting old system logs"
    LOG_COUNT=$(find /var/log -type f -name "*.log" | wc -l)
    LOG_SIZE_BEFORE=$(sudo du -ch /var/log/*.log | grep total$ | awk '{print $1}')
    sudo find /var/log -type f -name "*.log" -exec rm -fv {} \; >> $LOG_FILE
    sudo journalctl --vacuum-time=1d
    LOG_SIZE_AFTER=$(sudo du -ch /var/log/*.log | grep total$ | awk '{print $1}')
}

clean_swap() {
    info "Clearing swap..."
    log_action "Clearing swap"
    SWAP_CLEARED=$(free -h | grep Swap | awk '{print $3}')
    sudo swapoff -a && sudo swapon -a
}

clean_tmp() {
    info "Cleaning temporary files..."
    log_action "Cleaning temporary files"
    TMP_COUNT=$(find /tmp/* /var/tmp/* -type f | wc -l)
    TMP_SIZE_BEFORE=$(sudo du -ch /tmp/* /var/tmp/* | grep total$ | awk '{print $1}')
    sudo rm -rfv /tmp/* /var/tmp/* >> $LOG_FILE
    TMP_SIZE_AFTER=$(sudo du -ch /tmp/* /var/tmp/* | grep total$ | awk '{print $1}')
}

clean_browsers() {
    info "Cleaning browser caches..."
    log_action "Cleaning browser caches"
    BROWSER_COUNT=$(find ~/.cache/mozilla ~/.cache/google-chrome -type f | wc -l)
    BROWSER_SIZE_BEFORE=$(du -ch ~/.cache/mozilla ~/.cache/google-chrome | grep total$ | awk '{print $1}')
    rm -rfv ~/.cache/mozilla/firefox/*/*/cache2/* >> $LOG_FILE
    rm -rfv ~/.cache/google-chrome/* >> $LOG_FILE
    BROWSER_SIZE_AFTER=$(du -ch ~/.cache/mozilla ~/.cache/google-chrome | grep total$ | awk '{print $1}')
}

clean_brave_cache() {
    info "Cleaning Brave browser cache..."
    log_action "Cleaning Brave browser cache"
    BRAVE_COUNT=$(find ~/.cache/BraveSoftware -type f | wc -l)
    BRAVE_SIZE_BEFORE=$(du -ch ~/.cache/BraveSoftware | grep total$ | awk '{print $1}')
    rm -rfv ~/.cache/BraveSoftware/Brave-Browser/*/Cache/* >> $LOG_FILE
    BRAVE_SIZE_AFTER=$(du -ch ~/.cache/BraveSoftware | grep total$ | awk '{print $1}')
}

remove_old_kernels() {
    info "Removing old kernels..."
    log_action "Removing old kernels"
    sudo apt-get autoremove --purge -y
}

remove_unused_dependencies() {
    info "Removing unused dependencies..."
    log_action "Removing unused dependencies"
    sudo apt-get autoremove -y
}

free_up_ram() {
    info "Freeing up RAM..."
    log_action "Freeing up RAM"
    sync; echo 1 | sudo tee /proc/sys/vm/drop_caches
    sync; echo 2 | sudo tee /proc/sys/vm/drop_caches
    sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
}

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
    clean_all
    shift # past argument
    ;;
    -u|--update)
    update_system
    shift # past argument
    ;;
    -c|--cache)
    clean_cache
    shift # past argument
    ;;
    -t|--thumbnail)
    clean_thumbnail_cache
    shift # past argument
    ;;
    -l|--logs)
    clean_logs
    shift # past argument
    ;;
    -s|--swap)
    clean_swap
    shift # past argument
    ;;
    -T|--tmp)
    clean_tmp
    shift # past argument
    ;;
    -b|--browsers)
    clean_browsers
    shift # past argument
    ;;
    -B|--brave)
    clean_brave_cache
    shift # past argument
    ;;
    -r|--report)
    generate_system_report
    generate_cleaning_report
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

info "System cleanup complete."
log_action "System cleanup complete"
generate_system_report
generate_cleaning_report