# ⚠️ IMPORTANT DISCLAIMER - READ BEFORE USING ⚠️

## AI-Generated Project Warning

**This project was created with the assistance of artificial intelligence (AI).**

### ⚡ Critical Safety Notice

**THE AUTHOR TAKES NO RESPONSIBILITY FOR ANY DAMAGE, DATA LOSS, OR HARM CAUSED BY USING THIS SOFTWARE.**

By using this software, you acknowledge and agree that:

1. **No Warranty**: This software is provided "AS IS" without any warranty of any kind, express or implied.

2. **Data Loss Risk**: Creating Ventoy drives involves formatting USB drives, which **WILL ERASE ALL DATA** on the selected device.

3. **Use At Your Own Risk**: You assume full responsibility for any consequences of using this software.

4. **No Liability**: The author, contributors, and AI assistants involved in creating this project are **NOT LIABLE** for:
   - Data loss or corruption
   - Hardware damage
   - Boot failures
   - System instability
   - Any other damages or losses

5. **Verification Required**: Always verify you are selecting the correct USB drive before proceeding with any destructive operations.

### 🛡️ Recommended Precautions

- **Backup Important Data**: Always backup data before using disk formatting tools
- **Double-Check Device Selection**: Ensure you select the correct USB drive
- **Test First**: Test on non-critical systems/drives first
- **Understand the Risks**: Read and understand what each command does before executing

### 📋 About This Project

This repository contains:
- **Android App**: A Ventoy Manager application for Android
- **Termux Scripts**: Shell scripts for creating Ventoy drives via OTG on Android

### 🤖 AI Disclosure

This project was generated with AI assistance. While efforts were made to ensure correctness:
- Code may contain bugs or errors
- Not all edge cases may be handled
- Testing may be incomplete
- Security considerations may not be fully addressed

### 📞 No Support Guarantee

**NO OFFICIAL SUPPORT IS PROVIDED.**
Use community resources at your own discretion.

### ⚖️ Legal

By downloading, installing, or using this software, you agree to these terms and release the author from any and all liability.

**IF YOU DO NOT AGREE WITH THESE TERMS, DO NOT USE THIS SOFTWARE.**

---

## � Installation & Setup

### Option 1: Termux Method (Recommended - No Root Required)

The fastest way to create Ventoy drives on Android using OTG.

#### Prerequisites
- Android device with OTG support
- USB OTG adapter
- USB drive (8GB+)
- [Termux from F-Droid](https://f-droid.org/packages/com.termux/)

#### Quick Install (One Command)
```bash
curl -L https://raw.githubusercontent.com/1ARCH-USER1/VentoyAndroid/main/install-termux.sh | bash
```

#### Manual Setup
```bash
# Install dependencies
pkg update
pkg install curl tar parted exfat-utils

# Setup storage access
termux-setup-storage

# Download script
curl -L -o ventoy-termux.sh https://raw.githubusercontent.com/1ARCH-USER1/VentoyAndroid/main/ventoy-termux.sh
chmod +x ventoy-termux.sh

# Run
./ventoy-termux.sh create
```

#### Using Ventox Termux
```bash
# Create a new Ventoy drive
./ventoy-termux.sh create

# List connected USB drives
./ventoy-termux.sh list

# Copy ISO files to existing Ventoy drive
./ventoy-termux.sh copy
```

---

### Option 2: Android App

A full Android application for managing Ventoy drives.

#### Prerequisites
- Android Studio or Gradle
- Android SDK 33+
- JDK 17

#### Build from Source
```bash
# Clone repository
git clone https://github.com/1ARCH-USER1/VentoyAndroid.git
cd VentoyAndroid

# Setup environment (Linux/Mac)
export JAVA_HOME=/path/to/jdk-17
export ANDROID_HOME=/path/to/android-sdk

# Build APK
./gradlew assembleDebug

# Install to device
adb install app/build/outputs/apk/debug/app-debug.apk
```

#### Download Pre-built APK
*(Coming soon - GitHub Actions will build APK automatically)*

---

### Option 3: Direct Script Usage

If you already have Termux set up with required packages:

```bash
# Download main script only
curl -L -o ventoy-termux.sh https://raw.githubusercontent.com/1ARCH-USER1/VentoyAndroid/main/ventoy-termux.sh
chmod +x ventoy-termux.sh

# Use it
./ventoy-termux.sh create
```

---

## �📚 Project Overview

This repository provides tools for managing Ventoy bootable USB drives on Android devices:

### Components

1. **Ventoy Android Manager** (Android App)
   - Browse and copy ISO files
   - Manage USB drives
   - Modern Material Design 3 UI

2. **Ventoy Termux Scripts** (Termux/OTG)
   - Create Ventoy drives without root
   - USB OTG support
   - Automatic ISO detection

### Quick Links

- [Termux Installation Guide](TERMUX-README.md)
- [Android App Build Instructions](build_apk.sh)

---

**⚠️ USE AT YOUR OWN RISK ⚠️**
