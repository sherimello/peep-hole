#define MyAppName        "PeepHole"
#define MyAppVersion     "1.0.0"
#define MyAppPublisher   "PeepHole"
#define MyAppExeName     "peephole.exe"
#define MyAppSourceDir   "build\windows\x64\runner\Release"
#define MyAppIconFile    "windows\runner\resources\app_icon.ico"

[Setup]
AppId={{A3F2E1D0-9B4C-4E7A-8F3D-2C1B5A6E0D98}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=installer
OutputBaseFilename=PeepHole_Setup_{#MyAppVersion}
SetupIconFile={#MyAppIconFile}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "startup"; Description: "Launch PeepHole automatically when Windows starts (press Alt+X to open)"; GroupDescription: "Startup:"; Flags: checkedonce

[Files]
; Main executable
Source: "{#MyAppSourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; Flutter + plugin DLLs
Source: "{#MyAppSourceDir}\dartjni.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppSourceDir}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppSourceDir}\hotkey_manager_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppSourceDir}\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppSourceDir}\screen_retriever_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppSourceDir}\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppSourceDir}\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppSourceDir}\window_size_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion

; App data (Dart AOT snapshot + Flutter assets)
Source: "{#MyAppSourceDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Tasks: startup

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Start {#MyAppName} now (press Alt+X to open)"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "taskkill.exe"; Parameters: "/f /im {#MyAppExeName}"; Flags: runhidden waituntilterminated
