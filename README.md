<p align="center">
  <img src="assets/images/logo.png" alt="PeepHole Logo" width="120" />
</p>

<h1 align="center">PeepHole</h1>

<p align="center">
  A fast, keyboard-driven app launcher and file search for Windows — inspired by Spotlight and Raycast.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows-blue?logo=windows&logoColor=white" />
  <img src="https://img.shields.io/badge/built%20with-Flutter-54C5F8?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/version-1.0.0-brightgreen" />
  <img src="https://img.shields.io/badge/license-MIT-orange" />
  <img src="https://img.shields.io/badge/PRs-welcome-blueviolet" />
</p>

---

## What is PeepHole?

Press **Alt+X** anywhere on your desktop. PeepHole pops up instantly — type to search your installed apps, files, folders, or jump straight to a Google search. Press **Enter** to open, **Esc** to dismiss. It then disappears and stays out of your way.

No taskbar entry. No bloat. Just a fast, dark launcher that learns which results you open most and surfaces them first.

---

## Features

- **Global hotkey** — `Alt+X` summons the launcher from anywhere, even over fullscreen apps
- **Instant app search** — searches both user and system Start Menu shortcuts, shows real app icons
- **Smart file & folder search** — scans your home directories and builds a background in-memory index so results are near-instant after startup
- **Web fallback** — "Search on Google" tile is always pinned at the top for quick web lookups
- **Click-frequency ranking** — results you open most float to the top automatically over time
- **Keyboard navigation** — `↑` / `↓` to move, `Enter` to open, `Esc` to close
- **Drag to reposition** — grab the top bar to move the window anywhere on screen
- **Runs at startup** — optional, configured during install
- **Dark UI** — frameless, always-on-top, easy on the eyes

---

## Installation

### Option A — Installer (recommended)

Download the latest `PeepHole_Setup_x.x.x.exe` from [**Releases**](../../releases) and run it.

The installer will:
- Copy all files to `%ProgramFiles%\PeepHole`
- Optionally register a startup entry so it launches with Windows
- Create a Start Menu shortcut
- Include a clean uninstaller (`Control Panel → Apps → PeepHole`)

### Option B — Build from source

See [**Building Locally**](#building-locally) below.

---

## Usage

| Action | Key |
|---|---|
| Open PeepHole | `Alt+X` |
| Navigate results | `↑` / `↓` |
| Open selected result | `Enter` |
| Dismiss / clear | `Esc` |
| Move window | Drag the top bar |

**Result order:**
1. Previously opened results (most-clicked first, any type)
2. Installed apps
3. Folders
4. Files
5. "Search on Google" — always pinned at position #1

---

## Screenshots

> _Add screenshots or a demo GIF here._

---

## Tech Stack

| Package | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI framework (Windows desktop) |
| [window_manager](https://pub.dev/packages/window_manager) | Frameless, always-on-top window control |
| [hotkey_manager](https://pub.dev/packages/hotkey_manager) | System-wide `Alt+X` hotkey |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Persisting per-result open counts |
| [url_launcher](https://pub.dev/packages/url_launcher) | Opening web search results |
| Dart `Isolate` | Background file indexing without blocking the UI |
| [Inno Setup 6](https://jrsoftware.org/isinfo.php) | Windows installer generation |

---

## Building Locally

**Requirements**

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) ≥ 3.11 with Windows desktop support enabled
- Windows 10 or later (64-bit)
- Visual Studio 2022 with the **Desktop development with C++** workload

**Steps**

```powershell
# 1. Clone
git clone https://github.com/sherimello/peep-hole
cd peephole

# 2. Install dependencies
flutter pub get

# 3. Run in debug mode
flutter run -d windows

# 4. Build a release binary
flutter build windows --release
# Output: build\windows\x64\runner\Release\peephole.exe
```

**Building the installer** (requires [Inno Setup 6](https://jrsoftware.org/isinfo.php))

```powershell
flutter build windows --release
& "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe" "peep_hole_setup.iss"
# Output: installer\PeepHole_Setup_1.0.0.exe
```

---

## Project Structure

```
lib/
├── main.dart                        # Entry point — window setup, hotkey init
├── screens/
│   └── search_screen.dart           # Main UI: search bar + results list
├── services/
│   ├── search_service.dart          # Search orchestration, sorting, live scan
│   ├── index_service.dart           # Background in-memory file index (Isolate)
│   ├── hotkey_service.dart          # Alt+X global hotkey registration
│   ├── icon_service.dart            # App icon extraction from .lnk shortcuts
│   └── click_tracking_service.dart  # Persisted open-count per result path
├── widgets/
│   └── search_result_widget.dart    # Result row UI with real app icons
└── models/
    └── search_result.dart           # SearchResult model + SearchResultType enum

assets/
└── images/
    └── logo.png                     # App logo

windows/
└── runner/resources/app_icon.ico    # Windows icon (generated from logo.png)

peep_hole_setup.iss                  # Inno Setup installer script
```

---

## How the Search Works

1. **Apps** — scanned from `%ProgramData%` and `%APPDATA%` Start Menu folders at startup. Always fast.
2. **Files & folders** — on first search, a live scan of your home directories runs (Desktop, Documents, Downloads, and common dev folders). In parallel, a background `Isolate` builds a full in-memory index. Once ready (~5–30 seconds after launch), all subsequent searches query the index instantly.
3. **Ranking** — results are sorted by open count (descending), then by type: apps → folders → files. The web tile is always pinned at the top regardless of rank.

---

## Contributing

Contributions are welcome — bug reports, feature requests, and pull requests all appreciated.

**To contribute:**

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make your changes and test on Windows
4. Open a Pull Request with a clear description of what changed and why

**Ideas for contributors:**
- System tray icon so PeepHole is always visible
- Customisable hotkey via a settings page
- Calculator and unit conversion results
- Fuzzy matching instead of plain substring search
- macOS / Linux port (the underlying packages already support both)
- Plugin system for custom result providers

Please keep PRs focused — one feature or fix per PR makes review much easier.

---

## License

[MIT](LICENSE) — free to use, modify, and distribute.

If you find PeepHole useful, a ⭐ on the repo goes a long way.
