; Installer Windows (.exe) untuk Lakuna, dibuat dengan Inno Setup 6.
; Dipanggil dari release.yml:
;   iscc /DAppVersion=0.1.0 /DSourceDir=<folder Release> /DOutputDir=<keluaran> lakuna.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{6E8652A6-8E0B-4C9C-B4CC-BF48391F341A}
AppName=Lakuna
AppVersion={#AppVersion}
AppPublisher=Yusuf Abdillah Putra
AppPublisherURL=https://github.com/yusufabdillahputra/yap-lakuna
DefaultDirName={autopf}\Lakuna
DefaultGroupName=Lakuna
DisableProgramGroupPage=yes
PrivilegesRequiredOverridesAllowed=dialog
OutputDir={#OutputDir}
OutputBaseFilename=Lakuna-{#AppVersion}-windows-x64-setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\lakuna.exe
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; Bahasa Indonesia belum ada di paket resmi Inno Setup 6 (hanya terjemahan tidak resmi).

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Lakuna"; Filename: "{app}\lakuna.exe"
Name: "{autodesktop}\Lakuna"; Filename: "{app}\lakuna.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\lakuna.exe"; Description: "{cm:LaunchProgram,Lakuna}"; Flags: nowait postinstall skipifsilent
