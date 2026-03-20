; Inno Setup script to package Flutter Windows (x64) + install VC++ Runtime if needed.
; Build:
;   - Install Inno Setup 6
;   - (Optional) put vcredist_x64.exe into installer\redist\vcredist_x64.exe
;   - Run: .\installer\build-installer.ps1

#define AppName "POS Nimirik"
#define AppVersion "1.0.0"
#define AppPublisher "POS Nimirik"
#define AppURL ""
#define AppExeName "pos_interface.exe"

; Flutter output folder (relative to this .iss file)
#define SourceDir "..\\build\\windows\\x64\\runner\\Release"

; VC++ redistributable (optional)
#define VCRedistFile "redist\\vcredist_x64.exe"

#ifexist "{#VCRedistFile}"
  #define HasVCRedist "1"
#else
  #define HasVCRedist "0"
#endif

#ifnexist "{#SourceDir}\\{#AppExeName}"
  #error "Windows Release build not found. Run: flutter build windows --release (from apps\\pos_interface)."
#endif

#ifnexist "{#SourceDir}\\data\\icudtl.dat"
  #error "Flutter data folder missing (icudtl.dat). Re-run: flutter build windows --release and package the whole Release folder."
#endif

[Setup]
AppId={{7B75E2E5-0E0C-4D66-9A4D-59F725E72A02}}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=pos-nimirik-setup-{#AppVersion}
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a Desktop icon"; GroupDescription: "Icons"; Flags: unchecked

[Files]
; Copy Flutter app (exe, dll, data\flutter_assets, etc.)
Source: "{#SourceDir}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

#if "{#HasVCRedist}" == "1"
; Copy VC++ redistributable to %TEMP% to execute it
Source: "{#VCRedistFile}"; DestDir: "{tmp}"; Flags: deleteafterinstall
#endif

[Icons]
Name: "{autoprograms}\\{#AppName}"; Filename: "{app}\\{#AppExeName}"
Name: "{autodesktop}\\{#AppName}"; Filename: "{app}\\{#AppExeName}"; Tasks: desktopicon

[Run]
#if "{#HasVCRedist}" == "1"
; Install Visual C++ 2015-2022 (x64) if needed (fixes missing MSVCP140.dll)
Filename: "{tmp}\\vcredist_x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ runtime..."; Check: ShouldInstallVCRedist; Flags: waituntilterminated
#endif

; Launch the app at the end
Filename: "{app}\\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent

[Code]
function VCRedistInstalled(): Boolean;
var
  installed: Cardinal;
begin
  Result := False;

  ; VC++ 2015-2022 x64 runtime (14.x)
  if RegQueryDWordValue(HKLM64, 'SOFTWARE\\Microsoft\\VisualStudio\\14.0\\VC\\Runtimes\\x64', 'Installed', installed) then
  begin
    Result := (installed = 1);
  end;
end;

function ShouldInstallVCRedist(): Boolean;
begin
  Result := not VCRedistInstalled();
end;
