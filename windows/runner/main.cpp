#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <algorithm>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

void EnterKioskMode(HWND window) {
  const HMONITOR monitor = MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
  MONITORINFO monitor_info = {};
  monitor_info.cbSize = sizeof(monitor_info);
  if (!GetMonitorInfo(monitor, &monitor_info)) {
    return;
  }

  const LONG_PTR style = GetWindowLongPtr(window, GWL_STYLE);
  SetWindowLongPtr(
      window, GWL_STYLE,
      style & ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX |
                WS_MAXIMIZEBOX | WS_SYSMENU));
  SetWindowPos(
      window, HWND_TOP,
      monitor_info.rcMonitor.left,
      monitor_info.rcMonitor.top,
      monitor_info.rcMonitor.right - monitor_info.rcMonitor.left,
      monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top,
      SWP_FRAMECHANGED | SWP_SHOWWINDOW);
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  const bool live_mode =
      std::find(command_line_arguments.begin(), command_line_arguments.end(),
                "--live") != command_line_arguments.end();
  command_line_arguments.erase(
      std::remove(command_line_arguments.begin(), command_line_arguments.end(),
                  "--live"),
      command_line_arguments.end());

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size =
      live_mode ? Win32Window::Size(1080, 1920) : Win32Window::Size(540, 960);
  if (!window.Create(L"vm_ui", origin, size, !live_mode)) {
    return EXIT_FAILURE;
  }
  if (live_mode) {
    EnterKioskMode(window.GetHandle());
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
