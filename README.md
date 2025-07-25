<p align="center">
  <p align="center">
    <img src="./InjectHub.png" alt="Preview" width="128" />
  </p>
  <h1 align="center"><b>InjectHub</b></h1>
  <p align="center">
    <a href="README.md">English</a>
    <br />
    <br />
    <img src="https://img.shields.io/github/stars/NKR00711/InjectHub" alt="GitHub Stars" />
    <img src="https://img.shields.io/github/forks/NKR00711/InjectHub" alt="GitHub Forks" />
    <img src="https://img.shields.io/github/contributors/NKR00711/InjectHub" alt="Contributors" />
    <br />
    <a href="https://t.me/NKR00711"><img src="https://img.shields.io/badge/Contact%20me-Telegram-blue.svg" alt="Contact on Telegram" /></a>
    <a href="https://t.me/FreeIDMZone"><img src="https://img.shields.io/badge/Join%20Channel-Telegram-brightgreen.svg" alt="Join on Telegram Channel" /></a>
    <a href="https://t.me/FreeIDMZoneC"><img src="https://img.shields.io/badge/Join%20group-Telegram-brightgreen.svg" alt="Join Telegram Group" /></a>
  </p>
</p>

# Introduction

InjectHub is a powerful macOS utility designed to inject dynamic libraries (`.dylib`) into apps or binaries with ease. It provides a clean, native UI built using Swift and SwiftUI, offering tools for developers, researchers, and enthusiasts who need flexible and safe binary injection workflows.

---

## 🎯 Features

- 💉 **One-Click dylib Injection**  
  Select a `.dylib` and a target app/binary — InjectHub handles the rest.

- 🧠 **Auto Target Detection**  
  Automatically locates executable files inside `.app` bundles for injection.

- 🗃 **Saved Apps Panel**  
  Save your injected apps with metadata like Bundle ID, paths, and dylib info. Easily reload configurations with one click.

- 📋 **Live Console Logs**  
  See real-time feedback of every operation with options to copy or clear logs.

- 🧪 **Advanced Settings**  
  - Strip Code Signature  
  - Skip Backup  
  - Dummy Sign  
  - Auto Dequarantine  

- 📦 **Backup & Restore**  
  InjectHub creates backups before modifying targets. Restore anytime with a single click.

- 🔄 **Update System**  
  Built-in update checker with support for direct `.app` updates hosted online (e.g. GitHub).

---

## 🛠 Requirements

- macOS 14.0+  
- Inserted dylibs must be compatible with the target architecture

---

## 📦 Installation

### 🔹 Option 1: Using `.dmg` Installer (Recommended Method)

1. **Download** the latest `.dmg` from the [Releases page](https://github.com/NKR00711/InjectHub/releases).
2. Open the `.dmg` — a window will appear.
3. Double-click `install.sh` inside the DMG to Install.

---

### 🔹 Option 2: Using `.zip` Package (Minimal Download)

1. **Download** the `.zip` file from the [Releases page](https://github.com/NKR00711/InjectHub/releases).
2. Unzip it — you'll get `InjectHub.app`.
3. Move `InjectHub.app` to `/Applications`.
4. If macOS shows a security warning on first launch, run this command in Terminal to bypass Gatekeeper & sign the app:

    ```bash
    xattr -cr /Applications/InjectHub.app
    codesign -f -s - --deep /Applications/InjectHub.app
    ```

---

## ✅ Notes

- `xattr -cr` removes the "quarantine" flag that macOS adds when downloading unsigned apps.
- `codesign -f -s -` applies an **ad-hoc signature** so macOS accepts the app for local use.
- You only need to do this once per download.

## 📋 Quick Usage

1. Open the InjectHub application.
2. Select App/File to Inject.
3. Select Dylib File.
4. Click on Inject.
5. Done ✅.

## 🖼 Screenshots

<div align="center">
  <img src="./Screenshots/CleanShot 2025-07-16 at 17.58.38@2x.png" alt="Launch">
  <img src="./Screenshots/CleanShot 2025-07-16 at 17.47.22@2x.png" alt="App Selected">
</div>

## 🙏 Acknowledgements

Thanks to the following amazing projects that made InjectHub possible:

- [`insert_dylib`](https://github.com/Tyilo/insert_dylib) — A utility to inject a dylib into a Mach-O binary.
- [`marlkiller`](https://github.com/marlkiller) — Useful macOS reverse engineering tools and inspiration.
- [`InjectX`](https://github.com/inject-X/injectX) — an application injection tool designed for macOS.

