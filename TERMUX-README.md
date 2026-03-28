# Ventoy Termux - Android OTG USB Boot Creator

Create bootable USB drives with Ventoy directly from your Android device using Termux - **NO ROOT REQUIRED**!

## 🎯 Features

- ✅ **No Root Required** - Works with standard Termux permissions
- ✅ **OTG Support** - Create bootable USB drives via USB On-The-Go
- ✅ **Automatic ISO Detection** - Finds ISO files in Downloads folder
- ✅ **Easy Copy** - Copy ISO files to Ventoy drive from Android
- ✅ **Safe & Verified** - Confirms operations before erasing data
- ✅ **Offline Capable** - Downloads Ventoy once, reuses offline

## 📋 Requirements

1. **Android Device** with OTG support
2. **USB OTG Adapter** (USB-C or Micro-USB)
3. **USB Drive** (8GB or larger recommended)
4. **Termux App** (install from F-Droid)

## 🚀 Quick Start

### One-Line Installer

```bash
curl -L https://raw.githubusercontent.com/1ARCH-USER1/VentoyAndroid/main/install-termux.sh | bash
```

### Manual Installation

1. **Install Termux** from F-Droid (not Play Store version)

2. **Open Termux** and run:
   ```bash
   pkg update
   pkg install curl tar parted exfat-utils
   termux-setup-storage
   ```

3. **Download and install Ventoy Termux:**
   ```bash
   curl -L -o ventoy-termux.sh https://raw.githubusercontent.com/1ARCH-USER1/VentoyAndroid/main/ventoy-termux.sh
   chmod +x ventoy-termux.sh
   ```

## 💿 Creating a Ventoy Drive

### Step 1: Connect USB Drive
- Plug USB OTG adapter into Android device
- Insert USB drive into OTG adapter

### Step 2: Create Ventoy Drive
```bash
./ventoy-termux.sh create
```

The script will:
1. Detect your USB drive
2. Download Ventoy (first time only)
3. Install Ventoy bootloader
4. Verify installation
5. Optionally copy ISO files

### Step 3: Copy ISO Files
The script can automatically:
- Find ISO files in your Downloads folder
- Copy them to the Ventoy drive
- Show progress during copy

Or manually copy later using any file manager app.

## 📱 Usage Commands

```bash
# Create new Ventoy drive (interactive)
./ventoy-termux.sh create

# List connected USB drives
./ventoy-termux.sh list

# Copy ISO files to existing Ventoy drive
./ventoy-termux.sh copy

# Update Ventoy to latest version
./ventoy-termux.sh update

# Show help
./ventoy-termux.sh help
```

## 🔧 How It Works

### No-Root Method
This script uses Termux's built-in capabilities to:
- Access block devices via `/dev/block/`
- Use standard Linux utilities (parted, mkfs)
- Mount/unmount filesystems with Termux permissions
- Execute Ventoy's official installation script

### OTG Access
Android exposes USB drives as block devices:
- `/dev/block/sda`, `/dev/block/sdb`, etc.
- Script auto-detects removable USB storage
- Handles mounting/unmounting automatically

## ⚠️ Important Warnings

1. **DATA LOSS**: Creating Ventoy drive erases ALL data on USB drive
2. **CONFIRMATION REQUIRED**: Script requires typing "YES" to proceed
3. **UNMOUNT FIRST**: Ensure USB drive is not in use by other apps
4. **SAFE EJECT**: Always use Android's "Eject" before removing drive

## 🐛 Troubleshooting

### "No USB drives detected"
- Ensure OTG adapter is working
- Try different USB port on adapter
- Check `termux-setup-storage` has been run
- Some devices need USB debugging enabled

### "Permission denied"
- Run `termux-setup-storage` first
- Grant storage permission to Termux
- Try restarting Termux

### "Cannot unmount drive"
- Close file manager apps
- Eject drive from Android system first
- Reinsert USB drive and try again

### "Ventoy installation failed"
- Some devices require root for low-level disk access
- Try using `tsu` (Termux SU) if available
- Check USB drive is not write-protected

## 📂 ISO File Locations

The script automatically searches for ISO files in:
- `~/storage/downloads`
- `~/storage/shared/Download`
- `~/downloads`
- `~` (home directory)

You can also manually copy ISO files using:
```bash
cp /path/to/file.iso /path/to/usb/drive/
```

Or use any Android file manager with OTG support.

## 🔒 Security

- Script requires explicit confirmation for destructive operations
- Verifies drive selection before formatting
- Checks Ventoy installation after completion
- No root access required for basic functionality

## 📝 Technical Details

### What is Ventoy?
Ventoy is an open-source tool to create bootable USB drives:
- Copy ISO files directly to USB (no extraction needed)
- Boot multiple ISO files from single drive
- Supports 900+ ISO files (Windows, Linux, etc.)
- UEFI and Legacy BIOS support

### Block Device Access
Termux can access USB drives via:
```
/dev/block/sdX  (whole disk)
/dev/block/sdX1 (partition 1)
/dev/block/sdX2 (partition 2)
```

### Partitions Created
1. **EFI Partition** (FAT32) - Bootloader files
2. **Data Partition** (exFAT) - ISO storage

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Submit pull request

## 📜 License

This script is open-source and uses the same license as Ventoy (GPLv3+).

Ventoy itself is copyright © 2020-2024 longpanda (ventoy@foxmail.com)

## 🙏 Credits

- **Ventoy** - The amazing bootable USB solution by longpanda
- **Termux** - Powerful terminal emulator for Android
- **Android OTG** - USB On-The-Go specification

## 📞 Support

For issues with:
- **This script**: Open issue on GitHub
- **Ventoy itself**: Visit https://ventoy.net or GitHub ventoy/Ventoy
- **Termux**: Visit https://termux.dev

## 🔄 Updates

To update Ventoy to latest version:
```bash
./ventoy-termux.sh update
```

---

**Made with ❤️ for the Android and Ventoy communities**
