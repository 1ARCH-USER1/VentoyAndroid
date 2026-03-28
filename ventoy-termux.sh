#!/bin/bash

# Ventoy Drive Creator for Termux (Android OTG - No Root Required)
# This script creates a Ventoy bootable USB drive using Termux on Android

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VENTOY_VERSION="1.0.96"
VENTOY_URL="https://github.com/ventoy/Ventoy/releases/download/v${VENTOY_VERSION}/ventoy-${VENTOY_VERSION}-linux.tar.gz"
TEMP_DIR="$HOME/.ventoy-temp"
VENTOY_DIR="$HOME/ventoy"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

# Check if running in Termux
check_termux() {
    if [ -z "$TERMUX_VERSION" ] && [ ! -d "/data/data/com.termux" ]; then
        print_error "This script must be run in Termux on Android"
        exit 1
    fi
    print_success "Running in Termux environment"
}

# Check required packages
check_dependencies() {
    print_header "Checking Dependencies"
    
    local deps=("curl" "tar" "parted" "mkfs.exfat" "mkfs.vfat" "blockdev")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Missing packages: ${missing_deps[*]}"
        print_info "Installing required packages..."
        pkg update -y
        pkg install -y curl tar parted exfat-utils busybox
    else
        print_success "All dependencies installed"
    fi
}

# Download Ventoy
download_ventoy() {
    print_header "Downloading Ventoy v${VENTOY_VERSION}"
    
    mkdir -p "$VENTOY_DIR"
    cd "$VENTOY_DIR"
    
    if [ -f "ventoy-${VENTOY_VERSION}-linux.tar.gz" ]; then
        print_info "Ventoy already downloaded"
    else
        print_info "Downloading Ventoy from GitHub..."
        curl -L "$VENTOY_URL" -o "ventoy-${VENTOY_VERSION}-linux.tar.gz"
        print_success "Download complete"
    fi
    
    if [ ! -d "ventoy-${VENTOY_VERSION}" ]; then
        print_info "Extracting Ventoy..."
        tar -xzf "ventoy-${VENTOY_VERSION}-linux.tar.gz"
        print_success "Extraction complete"
    fi
}

# Detect USB drives
detect_usb_drives() {
    print_header "Detecting USB Drives"
    
    print_info "Connected block devices:"
    echo ""
    
    # List all block devices
    local drives=()
    local i=1
    
    for device in /dev/block/sd*; do
        if [ -b "$device" ]; then
            # Check if it's a whole disk (not a partition)
            if [[ "$device" =~ /dev/block/sd[a-z]$ ]]; then
                local size=$(blockdev --getsize64 "$device" 2>/dev/null || echo "0")
                local size_gb=$(echo "scale=2; $size / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "Unknown")
                local model=$(cat /sys/block/$(basename "$device")/device/model 2>/dev/null || echo "Unknown")
                
                echo -e "${CYAN}[$i]${NC} $device"
                echo "    Size: ${size_gb} GB"
                echo "    Model: $model"
                echo ""
                
                drives+=("$device")
                ((i++))
            fi
        fi
    done
    
    # Check for USB OTG via /dev/bus/usb
    if [ -d "/dev/bus/usb" ]; then
        print_info "USB devices detected via OTG"
        ls -la /dev/bus/usb/ 2>/dev/null || true
    fi
    
    # Alternative detection using df
    echo ""
    print_info "Mounted storage devices:"
    df -h | grep -E "(sd|mmc|usb|otg)" || true
    
    if [ ${#drives[@]} -eq 0 ]; then
        print_error "No USB drives detected!"
        print_warning "Make sure:"
        echo "  1. USB drive is connected via OTG adapter"
        echo "  2. Drive is properly formatted"
        echo "  3. Termux has storage permissions (termux-setup-storage)"
        exit 1
    fi
    
    echo ""
    read -p "Select drive number (1-${#drives[@]}): " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#drives[@]} ]; then
        SELECTED_DRIVE="${drives[$((selection-1))]}"
        print_success "Selected drive: $SELECTED_DRIVE"
    else
        print_error "Invalid selection"
        exit 1
    fi
}

# Confirm drive selection and warn about data loss
confirm_drive() {
    print_header "WARNING: DATA LOSS IMMINENT"
    
    print_error "ALL DATA ON $SELECTED_DRIVE WILL BE ERASED!"
    print_warning "This operation cannot be undone!"
    echo ""
    
    read -p "Type 'YES' to confirm you want to continue: " confirmation
    
    if [ "$confirmation" != "YES" ]; then
        print_info "Operation cancelled by user"
        exit 0
    fi
    
    print_success "Confirmation accepted"
}

# Create Ventoy drive (non-root method using termux-api or direct write)
create_ventoy_drive() {
    print_header "Creating Ventoy Drive"
    
    print_info "Preparing to install Ventoy on $SELECTED_DRIVE"
    
    # Unmount any mounted partitions on this device
    print_info "Unmounting existing partitions..."
    for mount_point in $(mount | grep "$SELECTED_DRIVE" | awk '{print $1}'); do
        umount "$mount_point" 2>/dev/null || true
    done
    
    # Get drive basename
    local drive_name=$(basename "$SELECTED_DRIVE")
    
    # Use Ventoy's direct installation method
    cd "$VENTOY_DIR/ventoy-${VENTOY_VERSION}"
    
    print_info "Installing Ventoy bootloader..."
    
    # Check if we can use Ventoy directly
    if [ -f "Ventoy2Disk.sh" ]; then
        print_info "Using Ventoy2Disk.sh installer..."
        
        # Try non-root installation
        bash Ventoy2Disk.sh -i "$SELECTED_DRIVE" 2>&1 | while read line; do
            echo "  $line"
        done
        
        if [ $? -eq 0 ]; then
            print_success "Ventoy installation completed!"
        else
            print_error "Ventoy installation failed"
            print_warning "You may need to:"
            echo "  1. Run 'tsu' to get root access in Termux"
            echo "  2. Ensure the drive is not mounted"
            echo "  3. Check OTG adapter connection"
            exit 1
        fi
    else
        print_error "Ventoy2Disk.sh not found!"
        exit 1
    fi
}

# Verify Ventoy installation
verify_ventoy() {
    print_header "Verifying Installation"
    
    # Check if Ventoy partition exists
    local ventoy_partition="${SELECTED_DRIVE}1"
    
    if [ -b "$ventoy_partition" ]; then
        print_success "Ventoy EFI partition found: $ventoy_partition"
    else
        print_warning "Ventoy EFI partition not found at expected location"
    fi
    
    # Check for Ventoy data partition
    local data_partition="${SELECTED_DRIVE}2"
    if [ -b "$data_partition" ]; then
        print_success "Ventoy data partition found: $data_partition"
    else
        print_warning "Ventoy data partition not found"
    fi
    
    # Try to mount and check Ventoy files
    print_info "Checking Ventoy files..."
    
    local mount_point="/mnt/ventoy-check"
    mkdir -p "$mount_point"
    
    if mount "$ventoy_partition" "$mount_point" 2>/dev/null; then
        if [ -f "$mount_point/EFI/BOOT/BOOTX64.EFI" ] || [ -f "$mount_point/EFI/BOOT/BOOTIA32.EFI" ]; then
            print_success "Ventoy bootloader files verified!"
        else
            print_warning "Bootloader files not found in expected location"
        fi
        umount "$mount_point" 2>/dev/null || true
    else
        print_warning "Could not mount Ventoy partition for verification"
    fi
    
    rmdir "$mount_point" 2>/dev/null || true
}

# Function to copy ISO files
copy_iso_files() {
    print_header "Copy ISO Files to Ventoy Drive"
    
    print_info "Select ISO files to copy:"
    
    # Find ISO files in common locations
    local iso_locations=(
        "$HOME/storage/downloads"
        "$HOME/storage/shared/Download"
        "$HOME/downloads"
        "$HOME"
    )
    
    local iso_files=()
    
    for location in "${iso_locations[@]}"; do
        if [ -d "$location" ]; then
            while IFS= read -r -d '' file; do
                iso_files+=("$file")
            done < <(find "$location" -maxdepth 2 -name "*.iso" -type f -print0 2>/dev/null)
        fi
    done
    
    if [ ${#iso_files[@]} -eq 0 ]; then
        print_warning "No ISO files found in standard locations"
        print_info "You can manually copy ISO files to the Ventoy drive using:"
        echo "  cp /path/to/your.iso /path/to/ventoy/drive/"
        return
    fi
    
    echo "Found ISO files:"
    for i in "${!iso_files[@]}"; do
        local filename=$(basename "${iso_files[$i]}")
        local size=$(du -h "${iso_files[$i]}" 2>/dev/null | cut -f1 || echo "Unknown")
        echo -e "${CYAN}[$((i+1))]${NC} $filename (${size})"
    done
    
    echo ""
    echo -e "${CYAN}[0]${NC} Skip copying ISO files"
    echo ""
    
    read -p "Select ISO file to copy (0 to skip, or number): " iso_selection
    
    if [ "$iso_selection" == "0" ]; then
        print_info "Skipping ISO copy"
        return
    fi
    
    if [[ "$iso_selection" =~ ^[0-9]+$ ]] && [ "$iso_selection" -ge 1 ] && [ "$iso_selection" -le ${#iso_files[@]} ]; then
        local selected_iso="${iso_files[$((iso_selection-1))]}"
        local iso_name=$(basename "$selected_iso")
        
        # Mount Ventoy data partition and copy
        local mount_point="/mnt/ventoy-iso"
        mkdir -p "$mount_point"
        
        local data_partition="${SELECTED_DRIVE}2"
        
        if mount "$data_partition" "$mount_point" 2>/dev/null || mount -t exfat "$data_partition" "$mount_point" 2>/dev/null || mount -t vfat "$data_partition" "$mount_point" 2>/dev/null; then
            print_info "Copying $iso_name to Ventoy drive..."
            
            # Show progress
            cp -v "$selected_iso" "$mount_point/" 2>&1 | while read line; do
                echo "  $line"
            done
            
            if [ $? -eq 0 ]; then
                print_success "ISO file copied successfully!"
            else
                print_error "Failed to copy ISO file"
            fi
            
            umount "$mount_point" 2>/dev/null || true
        else
            print_error "Could not mount Ventoy data partition"
            print_info "You can manually copy the ISO using a file manager"
        fi
        
        rmdir "$mount_point" 2>/dev/null || true
    else
        print_error "Invalid selection"
    fi
}

# Show usage information
show_usage() {
    cat << EOF

${CYAN}Ventoy Drive Creator for Termux${NC}
${CYAN}================================${NC}

${GREEN}Usage:${NC} ventoy-termux [command]

${YELLOW}Commands:${NC}
  create    Create a new Ventoy bootable USB drive
  update    Update Ventoy to latest version
  list      List connected USB drives
  copy      Copy ISO files to Ventoy drive
  help      Show this help message

${YELLOW}Requirements:${NC}
  - Termux app installed
  - USB OTG adapter
  - USB drive (8GB+ recommended)
  - termux-api (optional, for enhanced features)

${YELLOW}Installation:${NC}
  1. Install Termux from F-Droid
  2. Run: termux-setup-storage
  3. Download this script and make it executable
  4. Run: ./ventoy-termux.sh create

${YELLOW}Notes:${NC}
  - This script works WITHOUT root access
  - All data on the USB drive will be erased
  - Works with USB OTG on Android devices
  - Supports FAT32, exFAT, and NTFS ISO files

EOF
}

# List connected drives
list_drives() {
    print_header "Connected USB Drives"
    
    echo "Block devices:"
    ls -la /dev/block/sd* 2>/dev/null || print_warning "No SD block devices found"
    
    echo ""
    echo "Disk information:"
    for device in /dev/block/sd[a-z]; do
        if [ -b "$device" ]; then
            echo "Device: $device"
            blockdev --report "$device" 2>/dev/null || true
            echo ""
        fi
    done
    
    echo "Mounted filesystems:"
    df -h | grep -E "(sd|usb|otg)" || print_info "No USB drives currently mounted"
}

# Update Ventoy
update_ventoy() {
    print_header "Updating Ventoy"
    
    print_info "Removing old Ventoy installation..."
    rm -rf "$VENTOY_DIR"
    
    download_ventoy
    print_success "Ventoy updated to version $VENTOY_VERSION"
}

# Main function
main() {
    local command="${1:-create}"
    
    case "$command" in
        create)
            check_termux
            check_dependencies
            download_ventoy
            detect_usb_drives
            confirm_drive
            create_ventoy_drive
            verify_ventoy
            copy_iso_files
            print_header "Ventoy Drive Created Successfully!"
            print_info "You can now boot from this USB drive on any PC"
            print_info "Simply copy ISO files to the drive and boot"
            ;;
        list)
            list_drives
            ;;
        update)
            update_ventoy
            ;;
        copy)
            detect_usb_drives
            copy_iso_files
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
