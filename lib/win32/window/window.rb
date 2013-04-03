require 'win32/api'

class Win32::Rect < Struct.new(:left, :top, :right, :bottom)
end

class Win32::Point < Struct.new(:x, :y)
end

class Win32::Size < Struct.new(:width, :height)
end

module Win32::Geometry
  include Win32
  
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
  include Win32::Platform
  include Win32::Geometry

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

    # Enumerate through all windows and accumulate the matches.
    @@callback ||= API::Callback.new('LP', 'I') { |handle|
      opts = Thread.current[:opts]

      match = true
      if block_given?
        match &&= yield get_pid(handle), get_title(handle)
      else
        match &&= opts[:title].nil? || (get_title(handle) =~ opts[:title])
        match &&= opts[:pid].nil? || (get_pid(handle) == opts[:pid])
      end

      if match
        Thread.current[:matches] << Window.new(handle)
      end

      # Return 1 to continue the enumeration.
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
    Window.new(GetDesktopWindow.call)
  end

  def self.foreground
    Window.new(GetForegroundWindow.call)
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
    @handle == other.handle
  end

  def topmost?
    style = GetWindowLong.call(@handle, GWL_EXSTYLE)
    (style & WS_EX_TOPMOST) != 0
  end

  def topmost=(topmost)
    SetWindowPos.call(@handle, topmost ? HWND_TOPMOST : HWND_NOTTOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE)
  end

  def foreground?
    GetForegroundWindow.call == @handle
  end

  # Won't necessarily succeed.
  # See MSDN docs for restrictions.
  # Returns true if it worked, false otherwise.
  def foregroundize
    SetForegroundWindow.call(@handle) != 0
  end

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

  def restore
    if minimized?
      OpenIcon.call(@handle)
    end

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
    if Window.valid_handle?(parent)
      Window.new(parent)
    else
      nil
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

  # TODO: geometry should return special values when
  # the window is minimized.
  def geometry
    rect = Window.buffer(4 * 4)
    GetWindowRect.call(@handle, rect)
    left, top, right, bottom = rect.unpack('LLLL')

    # From GetWindowRect documentation: "In conformance with conventions for
    # the RECT structure, the bottom-right coordinates of the returned rectangle
    # are exclusive. In other words, the pixel at (right, bottom) lies immediately
    # outside the rectangle." Because of this, we decrement to determine the
    # inclusive coordinates.
    right -= 1
    bottom -= 1
    
    return Rect.new(left, top, right, bottom)
  end

  def client
    @client
  end

private
  class Client
    include Win32::Platform
    include Win32::Geometry

    def initialize(handle)
      @handle = handle
    end

    def geometry
      rect = Window.buffer(4 * 4)
      GetClientRect.call(@handle, rect)
      left, top, right, bottom = rect.unpack('LLLL')

      # From GetClientRect documentation: "In conformance with conventions for
      # the RECT structure, the bottom-right coordinates of the returned rectangle
      # are exclusive. In other words, the pixel at (right, bottom) lies immediately
      # outside the rectangle." Because of this, we decrement to determine the
      # inclusive coordinates.
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
