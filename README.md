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

### Build machine requirements

Build on Windows with the Flutter SDK and Visual Studio installed. In Visual
Studio Installer, select **Desktop development with C++**, including its Windows
SDK and C++ build tools. Also install the **C++ ATL for latest build tools
(x86 & x64)** individual component required by `flutter_secure_storage`.
See [Flutter Windows setup](https://docs.flutter.dev/platform-integration/windows/setup)
and the [Windows secure-storage plugin requirements](https://pub.dev/packages/flutter_secure_storage_windows/versions/4.1.0).

Validate the toolchain, install dependencies, and build with the API base URL:

```powershell
flutter doctor -v
flutter pub get
flutter build windows --release --dart-define=API_BASE_URL=https://cms.example.com/api
```

Replace the example URL with the actual API base URL, including its route prefix.
`API_BASE_URL` is a build-time setting; changing it requires rebuilding the app.

### Kiosk requirements and launch

Install the Microsoft Visual C++ Redistributable matching the build architecture
(x64 for the output below). The kiosk does not need Flutter, Visual Studio, or
C++ ATL development tools. See [Flutter Windows deployment requirements](https://docs.flutter.dev/platform-integration/windows/building#building-your-own-zip-file-for-windows).

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

## API client

`lib/core/network/api_client.dart` provides JSON GET, POST, PUT, PATCH and DELETE
methods, plus `request` for other methods. Set the complete base URL including
any API route prefix at build time:

```bash
flutter run -d linux --dart-define=API_BASE_URL=http://localhost:8080
flutter build linux --release --dart-define=API_BASE_URL=https://cms.example.com/api
```

Initialize Flutter bindings before creating the client, and reuse one client per
session. The following assumes imports for Flutter, dart:convert and api_client.dart:

```dart
WidgetsFlutterBinding.ensureInitialized();
final api = await ApiClient.create(); // Restores persisted credentials.
// After the separate pairing flow receives its response:
await api.setCredentials(MachineCredentials(
  machineId: machineId,
  token: pairingResponse['token'] as String,
  refreshToken: pairingResponse['refresh_token'] as String,
));
final response = await api.get('your-machine-endpoint');
final data = jsonDecode(response.body);
// await api.clearCredentials(); // Remove the local session when needed.
api.close();
```

Use `authenticated: false` for public requests or explicit Authorization headers.
Methods return `http.Response`, including empty 204 responses. Non-2xx responses
throw `ApiException` containing the status and API error message. Transport errors,
`TimeoutException`, and storage errors propagate. The configurable default timeout
is 30 seconds; timing out does not guarantee cancellation of server-side work.

An authenticated 401 triggers one refresh at `vending-machines/:id/refresh` and
one replay. The backend does not distinguish expired from otherwise invalid
access tokens in its 401 responses. Concurrent requests share a refresh; rejected
refresh credentials clear the session and require pairing again. Network and
server failures are not retried.

Machine ID and both tokens persist together through `flutter_secure_storage`,
scoped to the API base URL. Rotated tokens are saved automatically. Pairing screens
and endpoint-specific services remain separate from the wrapper. Tests can inject
an `http.Client` and `CredentialStore`.

### Linux secure storage

Install the native build dependency on Ubuntu/Debian:

```bash
sudo apt-get install libsecret-1-dev
```

Deployed kiosks require `libsecret-1-0` and an available, unlocked Secret Service
keyring (such as GNOME Keyring) in the kiosk user's desktop session. Credentials
belong to that operating-system user. See the
[secure-storage documentation](https://pub.dev/packages/flutter_secure_storage)
for platform setup details.

### Windows secure storage

The Windows plugin uses Windows Credential Manager to protect encryption keys
and stores encrypted token data in the application's support directory. No
separate keyring package is required. See the
[Windows storage implementation](https://pub.dev/packages/flutter_secure_storage_windows/versions/4.1.0).

Run the kiosk under the same Windows user account across restarts, and preserve
that user's application data and stored credentials during updates. Pair the
machine under its intended kiosk account; copying the release bundle alone does
not transfer an existing paired session to another account or machine.

Windows build and native credential persistence must be verified on Windows;
Linux builds and mocked storage tests do not validate the Windows implementation.

### Machine credential provisioning

Build the shared application with `API_BASE_URL`, then provision credentials on
the target kiosk by passing them to the built executable once. On Windows:

```powershell
.\vm_ui.exe `
  --vm-id 7 `
  --access-token "your-access-token" `
  --refresh-token "your-refresh-token"
```

On Linux:

```bash
./vm_ui \
  --vm-id 7 \
  --access-token 'your-access-token' \
  --refresh-token 'your-refresh-token'
```

All three arguments must be supplied together, and `--vm-id` must be a positive
integer. The credentials seed secure storage only when no session exists for
the configured CMS address. This preserves refreshed tokens on later launches.
To deliberately replace an existing session, supply the same three arguments
with `--replace-credentials`.

Command-line values can be visible in shell history and process inspection.
After provisioning succeeds, close the app and launch it again without the
credential arguments; subsequent launches restore the secure stored session.
