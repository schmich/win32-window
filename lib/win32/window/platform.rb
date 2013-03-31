require 'win32/api'

include Win32

module Win32::Platform
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633497(v=vs.85).aspx
  EnumWindows = API.new('EnumWindows', 'KP', 'L', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633520(v=vs.85).aspx
  GetWindowTextW = API.new('GetWindowTextW', 'LPI', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633519(v=vs.85).aspx
  GetWindowRect = API.new('GetWindowRect', 'IP', 'L', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633503(v=vs.85).aspx
  GetClientRect = API.new('GetClientRect', 'IP', 'L', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/dd183434(v=vs.85).aspx
  ClientToScreen = API.new('ClientToScreen', 'IP', 'L', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633545(v=vs.85).aspx
  SetWindowPos = API.new('SetWindowPos', 'IIIIIII', 'L', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633522(v=vs.85).aspx
  GetWindowThreadProcessId = API.new('GetWindowThreadProcessId', 'IP', 'L', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633504(v=vs.85).aspx
  GetDesktopWindow = API.new('GetDesktopWindow', '', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633505(v=vs.85).aspx
  GetForegroundWindow = API.new('GetForegroundWindow', '', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633510(v=vs.85).aspx
  GetParent = API.new('GetParent', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633527(v=vs.85).aspx
  IsIconic = API.new('IsIconic', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633531(v=vs.85).aspx
  IsZoomed = API.new('IsZoomed', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
  IsWindowVisible = API.new('IsWindowVisible', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
  ShowWindow = API.new('ShowWindow', 'II', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633558(v=vs.85).aspx
  WindowFromPoint = API.new('WindowFromPoint', 'LL', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms632673(v=vs.85).aspx
  BringWindowToTop = API.new('BringWindowToTop', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633528(v=vs.85).aspx
  IsWindow = API.new('IsWindow', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/ms633514(VS.85).aspx
  GetTopWindow = API.new('GetTopWindow', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633584(v=vs.85).aspx
  GetWindowLong = API.new('GetWindowLong', 'II', 'L', 'user32')

  INVALID_HANDLE_VALUE = -1

  SW_FORCEMINIMIZE = 11
  SW_HIDE = 0
  SW_MAXIMIZE = 3
  SW_MINIMIZE = 6
  SW_RESTORE = 9
  SW_SHOW = 5
  SW_SHOWDEFAULT = 10
  SW_SHOWMAXIMIZED = 3
  SW_SHOWMINIMIZED = 2
  SW_SHOWMINNOACTIVE = 7
  SW_SHOWNA = 8
  SW_SHOWNOACTIVATE = 4
  SW_SHOWNORMAL = 1

  HWND_BOTTOM = 1
  HWND_NOTTOPMOST = -2
  HWND_TOP = 0
  HWND_TOPMOST = -1

  SWP_NOSIZE = 0x0001
  SWP_NOZORDER = 0x0004
  SWP_NOMOVE = 0x0002

  WS_EX_TOPMOST = 0x00000008

  GWL_EXSTYLE = -20
end
