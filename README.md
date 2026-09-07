# vm_ui

Flutter UI for a portrait kiosk display.

The app uses a fixed 1080 × 1920 (9:16) design canvas. On development
machines, the canvas is scaled into a 540 × 960 window. On the kiosk, it can
run borderless and fullscreen by enabling kiosk mode.

## Development

Run the app in a resizable desktop window:

```bash
flutter run -d linux
```

Kiosk mode is off by default, so closing and moving the window remains
convenient during development.

## Build and run on a Linux kiosk

Build the release bundle on the target machine, or on a compatible Linux
build machine:

```bash
flutter build linux --release
```

The executable is generated at:

```text
build/linux/x64/release/bundle/vm_ui
```

Copy the entire `bundle` directory to the kiosk. The executable depends on the
libraries and data stored alongside it, so copying only the `vm_ui` file is not
enough.

Set the kiosk screen to portrait orientation in the operating system, then
enable fullscreen kiosk mode by setting `VM_UI_KIOSK_MODE=1` when launching:

```bash
cd /path/to/bundle
VM_UI_KIOSK_MODE=1 ./vm_ui
```

Kiosk mode makes the app borderless and fullscreen on the current display. The
1080 × 1920 canvas renders at 1:1 on a matching screen. Other resolutions are
scaled uniformly, with letterboxing if the display is not 9:16.

To return to windowed mode, close the app and launch it without the environment
variable:

```bash
./vm_ui
```

### Example kiosk launcher

For an autostart entry or service, use an absolute path and set the environment
variable as part of the launch command:

```bash
env VM_UI_KIOSK_MODE=1 /opt/vm-ui/bundle/vm_ui
```

The graphical desktop session and portrait display configuration must be ready
before this command starts.

## Build and run on a Windows kiosk

Build the Windows release:

```powershell
flutter build windows --release
```

The release output is generated under:

```text
build\windows\x64\runner\Release
```

Copy that complete directory to the kiosk. From PowerShell in the copied
directory, enable kiosk mode for the process and launch the app:

```powershell
$env:VM_UI_KIOSK_MODE = "1"
.\vm_ui.exe
```

The environment setting lasts for the current PowerShell session. To launch
normally in that session:

```powershell
Remove-Item Env:VM_UI_KIOSK_MODE
.\vm_ui.exe
```

## Tests

```bash
flutter test
```
