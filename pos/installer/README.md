# Windows installer (POS Nimirik)

This folder contains an **Inno Setup** script to generate a `setup.exe` for the Flutter Windows app.

## Why `MSVCP140.dll is missing`?

`MSVCP140.dll` is part of the **Microsoft Visual C++ Redistributable** (Visual Studio 2015-2022). Some Windows machines do not have it installed, so the app fails to start.

The installer below can (optionally) install this runtime automatically.

## Prerequisites

- Windows 10/11
- Flutter installed (to generate the Release build)
- Inno Setup 6 installed (to compile the installer)

## 1) Build Windows Release

From `apps\pos_interface`:

```powershell
flutter build windows --release
```

Make sure the following folder exists and contains `data\icudtl.dat`:

- `apps\pos_interface\build\windows\x64\runner\Release\`

## 2) (Optional) Bundle VC++ runtime into the installer

Download **Microsoft Visual C++ Redistributable 2015-2022 (x64)** (`vcredist_x64.exe`) from Microsoft, then put it here:

- `apps\pos_interface\installer\redist\vcredist_x64.exe`

If you do not include it, the installer will still be generated, but you must install the runtime manually on the target machine.

## 3) Build the installer

From the repo root:

```powershell
.\apps\pos_interface\installer\build-installer.ps1
```

Output:

- `apps\pos_interface\installer\Output\pos-nimirik-setup-1.0.0.exe`

## Quick manual fix (no installer)

On the machine with the error, install the VC++ redistributable (x64), then run the app again.
