# PeepHole - Advanced Windows Search Application

**PeepHole** is a high-performance, global hotkey-triggered search application for Windows that instantly searches across files, folders, installed applications, with smart web search suggestions.

## Features

✨ **Global Hotkey Trigger**
- Press `Alt+S` from anywhere to instantly open the search interface
- Window appears centered on screen

🔍 **Comprehensive Search**
- **Files**: Deep search across all drives (up to 4 levels)
- **Folders**: Quick access to directory locations
- **Installed Apps**: Searches Program Files and common app locations
- **Web Search**: Integrated Google search suggestions

⚡ **Smart Features**
- Real-time search results (up to 20 results)
- Keyboard navigation (↑↓ arrows)
- Press Enter to open selected result
- Press ESC to close/clear
- Clean, modern dark theme UI
- Frameless elegant design

🎯 **Quick Actions**
- Click file to open it
- Click folder to open in File Explorer
- Click app to launch it
- Click web search to perform Google search

## Installation

### Standalone Executable
Simply run `peephole.exe` from the build folder:
```
build\windows\x64\runner\Release\peephole.exe
```

Or create a shortcut to launch it automatically on startup.

### Startup Integration
To launch PeepHole automatically on Windows startup:
1. Right-click `peephole.exe` and select "Create shortcut"
2. Move the shortcut to `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup`

## Usage

### Basic Usage
1. Press `Alt+S` anywhere on your screen
2. Type your search query
3. Use arrow keys to navigate results
4. Press Enter to open the selected result
5. Press ESC to close

### Search Tips
- **Fast file search**: Type filename or partial name
- **App search**: Type app name to launch quickly
- **Folder search**: Type folder name to navigate
- **Web search**: Any search triggers Google web search option

## Technical Details

### Architecture
- **Framework**: Flutter (Dart)
- **Target**: Windows (x64)
- **Key Libraries**:
  - `window_manager`: Frameless window management
  - `hotkey_manager`: Global hotkey registration
  - `path_provider`: Path utilities
  - `url_launcher`: Web browser integration

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── screens/
│   └── search_screen.dart      # Main search UI
├── services/
│   ├── hotkey_service.dart     # Alt+S hotkey handling
│   └── search_service.dart     # File/folder/app search logic
├── models/
│   └── search_result.dart      # Search result data model
└── widgets/
    └── search_result_widget.dart # Result item UI
```

## Search Result Indicators

- 🔵 **Blue Icon**: File
- 🟠 **Orange Icon**: Folder
- 🟢 **Green Icon**: Application
- 🔷 **Light Blue Icon**: Web Search

## System Requirements

- Windows 10 or later
- 64-bit processor
- ~50MB disk space for application

## Troubleshooting

### Hotkey not working
- Ensure PeepHole is running in background
- Some apps may intercept hotkeys - try with different application active
- Administrator privileges may be required for system-wide hotkey

### Search is slow
- First search indexes system - subsequent searches are faster
- Avoid searching immediately after boot
- System drives with many files take longer to index

### Can't open certain files
- Ensure file associations are set up in Windows
- Some system files may be restricted

## Performance Notes

- Search results limited to 20 items (most relevant shown)
- Search depth limited to 4 directory levels to ensure responsiveness
- System folders and common cache directories are skipped
- First search may take 1-3 seconds depending on system

## Building from Source

If you want to build from source:

```bash
# Navigate to project directory
cd c:\dev\peep hole

# Get dependencies
flutter pub get

# Build for Windows
flutter build windows --release

# Executable will be at:
# build\windows\x64\runner\Release\peephole.exe
```

## Development Mode

To run in development mode with hot reload:
```bash
flutter run -d windows
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Alt+S` | Show/focus search window |
| `↑` / `↓` | Navigate results |
| `Enter` | Open selected result |
| `ESC` | Close search window / Clear search |

---

**Enjoy blazing-fast searching!** ⚡
# peep-hole
