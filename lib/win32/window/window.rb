require 'win32/api'
include Win32

module Win32
  class Rect < Struct.new(:left, :top, :right, :bottom)
  end

  class Point < Struct.new(:x, :y)
  end

  class Size < Struct.new(:width, :height)
  end

  class Window
    def initialize(handle)
      @handle = handle
    end

    def self.find(opts = {})
      Thread.current[:matches] = []
      Thread.current[:opts] = opts

      @@callback ||= API::Callback.new('LP', 'I') { |handle|
        opts = Thread.current[:opts]

        match = true
        match &&= opts[:title].nil? || (get_title(handle) =~ opts[:title])
        match &&= opts[:pid].nil? || (get_pid(handle) == opts[:pid])

        if match
          Thread.current[:matches] << Window.new(handle)
        end

        1
      }

      EnumWindows.call(@@callback, nil)

      return Thread.current[:matches]
    end

    def self.desktop
      Window.new(GetDesktopWindow.call())
    end

    def self.foreground
      Window.new(GetForegroundWindow.call())
    end

    def title
      Window.get_title(@handle)
    end

    def handle
      @handle
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      handle == other.handle
    end

    def topmost=(topmost)
      SetWindowPos.call(@handle, topmost ? HWND_TOPMOST : HWND_NOTTOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE)
    end

    def minimize
      CloseWindow.call(@handle)
    end

    def minimized?
      IsIconic.call(@handle) != 0
    end

    def visible?
      IsWindowVisible.call(@handle) != 0
    end

    def hide
    end

    def show
    end

    def parent
      parent = GetParent.call(@handle)
      if parent == 0
        nil
      else
        Window.new(parent)
      end
    end

    def pid
      Window.get_pid(@handle)
    end

    def move(x, y)
      SetWindowPos.call(@handle, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER)
    end

    def resize(width, height)
      SetWindowPos.call(@handle, 0, 0, 0, width, height, SWP_NOMOVE | SWP_NOZORDER)
    end

    def location
      g = geometry()
      Point.new(g.left, g.top)
    end

    def x
    end

    def y
    end

    def left
    end

    def right
    end

    def top
    end
    
    def bottom
    end

    def size
      g = geometry()
      Size.new(g.right - g.left, g.bottom - g.top)
    end

    def width
    end

    def height
    end

    def geometry
      rect = Window.buffer(4 * 4)
      GetWindowRect.call(@handle, rect)
      left, top, right, bottom = rect.unpack('LLLL')
      return Rect.new(left, top, right, bottom)
    end

    def client_geometry
      rect = Window.buffer(4 * 4)
      GetClientRect.call(@handle, rect)
      left, top, right, bottom = rect.unpack('LLLL')

      width = right - left
      height = bottom - top

      point = point(left, top)
      ClientToScreen.call(@handle, point)
      screen_left, screen_top = point.unpack('LL')

      return Rect.new(screen_left, screen_top, screen_left + width, screen_top + height)
    end

  private
    def self.get_title(handle)
      if GetWindowTextW.call(handle, buffer = "\0" * 1024, buffer.length) == 0
        nil
      else
        buffer.force_encoding('utf-16LE').encode('utf-8').rstrip
      end
    end

    def self.get_pid(handle)
      buf = buffer(4)
      GetWindowThreadProcessId.call(handle, buf)
      buf.unpack('L')[0]
    end

    def self.buffer(bytes)
      ' ' * bytes
    end

    def point(x, y)
      [x, y].pack('LL')
    end
  end

  EnumWindows = API.new('EnumWindows', 'KP', 'L', 'user32')
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

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms632678(v=vs.85).aspx
  CloseWindow = API.new('CloseWindow', 'I', 'L', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633504(v=vs.85).aspx
  GetDesktopWindow = API.new('GetDesktopWindow', '', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633505(v=vs.85).aspx
  GetForegroundWindow = API.new('GetForegroundWindow', '', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633510(v=vs.85).aspx
  GetParent = API.new('GetParent', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633527(v=vs.85).aspx
  IsIconic = API.new('IsIconic', 'I', 'I', 'user32')

  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
  IsWindowVisible = API.new('IsWindowVisible', 'I', 'I', 'user32')

  HWND_BOTTOM = 1
  HWND_NOTTOPMOST = -2
  HWND_TOP = 0
  HWND_TOPMOST = -1

  SWP_NOSIZE = 0x0001
  SWP_NOZORDER = 0x0004
  SWP_NOMOVE = 0x0002
end
