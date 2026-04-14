# Studio OS

> A fully self-contained creative OS inside a single Android APK.
> Target: **Samsung Galaxy S21 FE** (Android 12+, ARM64). No root required.

---

## What is Studio OS?

Studio OS is a miniature creative computer packaged as one Android APK. It provides a guided, menu-driven environment where you can:

- 🌐 **Create websites** — HTML/CSS wizard with live preview
- 💻 **Write programs** — Shell, Python, Node.js, C scripts
- 🤖 **Build AI helpers** — Rule-based bots, upgradeable to real AI APIs
- ⚙️ **Set up custom OS environments** — Sandboxed mini-environments
- 🛠️ **Use built-in tools** — Text editor, file manager, HTTP server, terminal
- 🩺 **Run Studio Doctor** — Scan and repair your Studio OS installation
- 📚 **Learn from tutorials** — Step-by-step guides built-in

Everything runs **inside the app sandbox** at `/data/data/com.studio.os/files/`. No root, no system modifications.

---

## Project Structure

```
StudioOS/
├── app/
│   ├── src/main/
│   │   ├── java/com/studio/os/
│   │   │   ├── StudioActivity.kt     — Jetpack Compose UI
│   │   │   ├── EngineBridge.kt       — Shell process backend
│   │   │   ├── StudioWidget.kt       — Home screen widget
│   │   │   ├── EngineService.kt      — Foreground service
│   │   │   └── StudioApp.kt          — Application class
│   │   ├── cpp/
│   │   │   ├── bootstrap.c           — Native JNI bootstrap
│   │   │   └── CMakeLists.txt
│   │   ├── assets/system-base/
│   │   │   ├── core/
│   │   │   │   ├── boot              — Entry point
│   │   │   │   ├── shell             — Main REPL loop
│   │   │   │   ├── menus/            — All menu scripts
│   │   │   │   ├── wizards/          — Creation wizards
│   │   │   │   ├── doctor/           — Studio Doctor scanner
│   │   │   │   └── tutorials/        — Built-in tutorials
│   │   │   └── (bin/, usr/bin/, home/, profiles/, state/)
│   │   ├── res/
│   │   │   ├── layout/widget_studio.xml
│   │   │   ├── xml/studio_widget_info.xml
│   │   │   ├── drawable/
│   │   │   └── values/
│   │   └── AndroidManifest.xml
│   ├── build.gradle
│   └── proguard-rules.pro
├── build.gradle
├── settings.gradle
├── gradle.properties
├── build-termux.sh           — Build the APK from Termux
└── README.md
```

---

## Building from Termux (on your phone)

```bash
# 1. Clone the repo
pkg install git
git clone https://github.com/Cbetts1/STUDIO_DEV
cd STUDIO_DEV

# 2. Run the build script (downloads SDK + NDK automatically)
bash build-termux.sh debug

# 3. Install the APK
# Option A — via ADB (if connected to PC):
adb install -r StudioOS-debug.apk

# Option B — open APK directly in Android Files app
# (Settings → Security → allow Unknown Sources first)
```

---

## Building from Android Studio / PC

```bash
./gradlew assembleDebug
# APK: app/build/outputs/apk/debug/app-debug.apk
```

---

## Device Requirements

| | |
|---|---|
| Device | Samsung Galaxy S21 FE (or any ARM64 Android) |
| OS | Android 12+ (API 31+) |
| CPU | ARM64 |
| Root | ❌ Not required |
| System mods | ❌ None |
| Storage | ~20 MB for app, + space for your projects |

---

## Architecture

```
┌────────────────────────────────────────┐
│          Jetpack Compose UI            │
│  (StudioActivity.kt — dark terminal)   │
└──────────────────┬─────────────────────┘
                   │ reads/writes
┌──────────────────▼─────────────────────┐
│           EngineBridge.kt              │
│  • Extracts assets on first run        │
│  • Spawns /system/bin/sh as process    │
│  • Streams output lines to UI          │
│  • Sends user input to stdin           │
└──────────────────┬─────────────────────┘
                   │ exec
┌──────────────────▼─────────────────────┐
│     assets/system-base/core/boot       │
│     → core/shell (REPL loop)           │
│       → menus/ wizards/ doctor/        │
│         tutorials/ terminal/           │
└────────────────────────────────────────┘
```

---

## License

MIT — build it, hack it, ship it.
Made easy studio for phon
