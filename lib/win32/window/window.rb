require 'win32/api'

include Win32::Platform

class Win32::Rect < Struct.new(:left, :top, :right, :bottom)
end

class Win32::Point < Struct.new(:x, :y)
end

class Win32::Size < Struct.new(:width, :height)
end

module Win32::Geometry
  def location
    g = geometry()
    Point.new(g.left, g.top)
  end

  def x
    location.x
  end

  def y
    location.y
  end

  def left
    geometry.left
  end

  def right
    geometry.right
  end

  def top
    geometry.top
  end
  
  def bottom
    geometry.bottom
  end

  def size
    g = geometry()
    Size.new(g.right - g.left + 1, g.bottom - g.top + 1)
  end

  def width
    size.width
  end

  def height
    size.height
  end
end

class Win32::Window
  def initialize(handle)
    if !Window.valid_handle?(handle)
      raise ArgumentError, 'Invalid handle.'
    end

    @handle = handle
    @client = Client.new(@handle)
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

  def self.from_point(*args)
    if (args.length == 1) && (args[0].is_a? Point)
      x = args[0].x
      y = args[0].y
    elsif args.length == 2
      x, y = args
    else
      raise ArgumentError
    end

    handle = WindowFromPoint.call(x,y)
    if Window.valid_handle?(handle)
      Window.new(handle)
    else
      nil
    end
  end

  def self.from_handle(handle)
    if Window.valid_handle?(handle)
      Window.new(handle)
    else
      nil
    end
  end

  # See also GetShellWindow
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633512(v=vs.85).aspx
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

  def topmost?
  end

  def topmost=(topmost)
    SetWindowPos.call(@handle, topmost ? HWND_TOPMOST : HWND_NOTTOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE)
  end

  # Use also SetForegroundWindow?
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633539(v=vs.85).aspx
  # def bring_to_top
  #   BringWindowToTop.call(@handle)
  # end

  def focus
    # ...?
  end

  def focused?
  end

  # window.children.from_point(...)
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms632677(v=vs.85).aspx
  # ChildWindowFromPointEx

  # window.children.each/window.each_child
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633494(v=vs.85).aspx
  # EnumChildWindows

  # window.children.topmost
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633514(v=vs.85).aspx
  # GetTopWindow

  # window.child_of?
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633524(v=vs.85).aspx
  # IsChild

  def minimize
    ShowWindow.call(@handle, SW_MINIMIZE)
  end

  def minimized?
    IsIconic.call(@handle) != 0
  end

  def maximize
    ShowWindow.call(@handle, SW_MAXIMIZE)
  end

  def maximized?
    IsZoomed.call(@handle) != 0
  end

  # TODO: max -> min -> restore does not show the window restored,
  # you have to do max -> min -> restore -> restore.
  def restore
    ShowWindow.call(@handle, SW_RESTORE)
  end

  def visible?
    IsWindowVisible.call(@handle) != 0
  end

  # TODO: hide -> maximize/minimize/restore forces the window
  # to be shown again, use SetWindowPlacement?
  def hide
    ShowWindow.call(@handle, SW_HIDE)
  end

  def show
    ShowWindow.call(@handle, SW_SHOW)
  end

  def parent
    parent = GetParent.call(@handle)
    if parent == 0
      nil
    else
      Window.new(parent)
    end
  end

  # See GetAncestor
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633502(v=vs.85).aspx
  def root
  end

  # See GetAncestor
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633502(v=vs.85).aspx
  def owner
    # ...
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

  include Geometry

  # TODO: geometry should return special values when
  # the window is minimized.
  def geometry
    rect = Window.buffer(4 * 4)
    GetWindowRect.call(@handle, rect)
    
    left, top, right, bottom = rect.unpack('LLLL')
    return Rect.new(left, top, right, bottom)
  end

  def client
    @client
  end

  # See GetWindowModuleFileName
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms633517(v=vs.85).aspx
  def module_name
  end

private
  class Client
    def initialize(handle)
      @handle = handle
    end

    include Geometry

    def geometry
      rect = Window.buffer(4 * 4)
      GetClientRect.call(@handle, rect)
      left, top, right, bottom = rect.unpack('LLLL')

      # From GetClientRect documentation: "In conformance with conventions for
      # the RECT structure, the bottom-right coordinates of the returned rectangle
      # are exclusive. In other words, the pixel at (right, bottom) lies immediately
      # outside the rectangle."
      # Because of this, we decrement to determine the inclusive coordinate.
      right -= 1
      bottom -= 1

      width = right - left + 1
      height = bottom - top + 1

      top_left = Window.point(left, top)
      ClientToScreen.call(@handle, top_left)
      screen_left, screen_top = top_left.unpack('LL')

      screen_right = screen_left + width - 1
      screen_bottom = screen_top + height - 1

      return Rect.new(screen_left, screen_top, screen_right, screen_bottom)
    end
  end

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
    "\0" * bytes
  end

  def self.point(x, y)
    [x, y].pack('LL')
  end

  def self.valid_handle?(handle)
    (handle != 0) && (handle != INVALID_HANDLE_VALUE) && (IsWindow.call(handle))
  end
end
