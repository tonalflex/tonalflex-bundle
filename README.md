# TonalFlex Bundle

This repository contains the installer script for running the complete **TonalFlex app bundle** on a Raspberry Pi running [Elk Audio OS](https://www.elk.audio/).

The installer fetches and installs the latest versions of all required core components and plugins from the official TonalFlex release repositories.

---

## 🔧 Requirements

- Raspberry Pi running [Elk Audio OS](https://github.com/elk-audio/elk-pi)
- Internet connection
- SSH access to the device

---

## 🚀 Quick Start

### 1. SSH into your Elk Pi device

```sh
ssh mind@elk-pi.local
```

**Default password:** `elk`

_Replace elk-pi.local with your device's IP address if needed._

### 2. Download and run the installer

```sh
cd /home/mind
git clone https://github.com/tonalflex/tonalflex-bundle.git
cd tonalflex-bundle
chmod +x install.sh
./install.sh
```

When prompted, enter the device password to allow installation of system binaries.

---

## 📦 What it installs

The script reads from [`manifest.json`](./manifest.json) to download and install:

- **Core binaries** (e.g. `ui-server`, `butler`, `envoy`)  
  → Installed to `/bin`

- **Plugins** (VST3 Audio DSP Processors)  
  → Installed to `/home/mind/plugins`

It handles downloading, extracting `.tar.gz` files, and setting executable permissions automatically.

---

## 📄 License

This project is licensed under the terms of the [LICENSE](./LICENSE) file included in this repository.

---
