# PeepHole - Quick Start Guide

## First Time Setup

### 1. Download & Run
- Download `peephole.exe` from `build\windows\x64\runner\Release\peephole.exe`
- Double-click to run
- The app will minimie to system tray (or background)

### 2. First Use
- Press **`Alt+S`** anywhere on your Windows screen
- A sleek search window will appear in the center
- Start typing what you're looking for

## How to Search

### Type and Find
```
Files:      "document.pdf" or "photo"
Folders:    "Downloads" or "Desktop"
Apps:       "Notepad" or "Chrome"
Web:        Anything not found locally
```

### Navigate Results
```
↑ ↓         - Move up/down in results
Enter       - Open the selected item
Esc         - Close search / Clear text
Backspace   - Delete characters
```

## What Happens When You Open Results

| Result Type | Action |
|-------------|--------|
| 📄 File | Opens with default program |
| 📁 Folder | Opens in File Explorer |
| 🎮 App | Launches the application |
| 🌐 Web | Searches on Google |

## Examples

### Finding a File
```
1. Press Alt+S
2. Type: "budget"
3. See: All files with "budget" in name
4. Press Down arrow
5. Press Enter to open selected file
```

### Launching an App
```
1. Press Alt+S
2. Type: "VS Code"
3. See: Visual Studio Code in results
4. Press Enter to launch
```

### Quick Web Search
```
1. Press Alt+S
2. Type: "flutter widgets"
3. Scroll down to "Search: flutter widgets"
4. Press Enter to open Google search
```

## Tips & Tricks

💡 **Search is case-insensitive**
- Type: `DESKTOP` or `desktop` - both work

💡 **Partial matches work**
- Type: `pdf` finds `document.pdf`, `forms.pdf`, etc.

💡 **Use common shortcuts**
- Most apps can be found by typing first few letters
- VS = Visual Studio
- PS = PowerShell
- PY = Python

💡 **Quick system access**
- Type: `appdata` to access User AppData folder
- Type: `temp` to access Temp folder
- Type: `windows` to access Windows folder

## Customization

### Hotkey Alternative
If Alt+S doesn't work in your app:
- Try using it in different applications
- Some apps may have their own Alt+S shortcut
- Admin mode might be required

### Auto-Start
To run PeepHole automatically on Windows startup:

**Option 1: Startup Folder**
1. Press `Windows + R`
2. Type: `shell:startup`
3. Drag `peephole.exe` shortcut here

**Option 2: Task Scheduler**
1. Open Task Scheduler
2. Create Basic Task
3. Name: "PeepHole Search"
4. Trigger: At login
5. Action: Start program → peephole.exe

## Performance Tips

⚡ **First search is slow (1-2 seconds)**
- Subsequent searches are instant (cached)

⚡ **Faster results with specific queries**
- "photo.jpg" faster than "p"
- "Downloads" faster than "d"

⚡ **Avoid searching during system startup**
- Wait 30 seconds after boot

## Troubleshooting

### Alt+S doesn't trigger search?
✓ Check if PeepHole is running
✓ Try pressing it in a different app
✓ May need Administrator mode
✓ Restart PeepHole

### Search results are slow?
✓ First search indexes the system
✓ Subsequent searches are much faster
✓ Wait a moment, results are loading
✓ Try restarting the app

### Can't open a file?
✓ Check if file association is set (right-click > Open with)
✓ Try opening it manually first
✓ Some system files are protected

### No apps showing up?
✓ Apps are searched in Program Files
✓ If not installed there, try searching by filename
✓ Manually launch app once to register it

## Keyboard Reference

```
Alt+S           Open/Focus PeepHole
↑               Previous result
↓               Next result
Enter           Open selected result
Esc             Close search window
Ctrl+A          Select all search text
Backspace       Delete character
Delete          Delete character
A-Z, 0-9        Type search query
```

## Uninstalling

Simply delete `peephole.exe`. No installation, no registry entries!

---

**Questions? Check the main README.md for technical details!**
