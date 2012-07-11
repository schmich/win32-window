require 'win32/window'
require 'test/unit'
require 'win32/semaphore'
require 'shared'

class TestWin32Window < Test::Unit::TestCase
  def setup
    semaphore = Win32::Semaphore.new(0, 1, $semaphore)
    app = File.join(File.dirname(__FILE__), 'app.rb')
    @pid = Process.spawn('rubyw.exe', app)
    semaphore.wait()
    @w = Window.find(:pid => @pid).first
  end

  def teardown
    Process.kill('KILL', @pid)
  end

  def test_find_title
    w = Window.find(:title => /\A#{$title}\z/)
    assert(!w.empty?)
  end

  def test_find_pid
    w = Window.find(:pid => @pid)
    assert(!w.empty?)
  end

  def test_pid
    w = Window.find(:pid => @pid).first
    assert_equal(w.pid, @pid)
  end

  def test_title
    w = Window.find(:title => /\A#{$title}\z/).first
    assert_equal(w.title, $title)
  end

  def test_handle
    assert_not_equal(0, @w.handle)
  end

  def test_size
  end

  def test_move
    @w.move(10, 20)
    loc = @w.location
    assert_equal(10, loc.x)
    assert_equal(20, loc.y)
    @w.move(40, 30)
    loc = @w.location
    assert_equal(40, loc.x)
    assert_equal(30, loc.y)
  end

  def test_visible
    assert(@w.visible?)
  end

  def test_hide_show
    @w.hide
    assert(!@w.visible?)
    @w.show
    assert(@w.visible?)
  end

  def test_minimize
    assert(!@w.minimized?)
    assert(!@w.maximized?)
    @w.minimize
    assert(@w.minimized?)
    assert(!@w.maximized?)
  end

  def test_maximize
    assert(!@w.maximized?)
    assert(!@w.minimized?)
    @w.maximize
    assert(@w.maximized?)
    assert(!@w.minimized?)
  end

  def test_desktop
    assert_not_equal(nil, Window.desktop)
  end

  def test_foreground
    assert_not_equal(nil, Window.foreground)
    assert_equal(@w, Window.foreground) 
  end

  def test_equality
    p = Window.find(:pid => @pid).first
    q = Window.find(:pid => @pid).first
    assert(p == q)
    assert(p.eql? q)
    assert(!(p != q))
    p = Window.find(:pid => @pid).first
    q = Window.find(:title => /\A#{$title}\z/).first
    assert(p == q)
    assert(p.eql? q)
    assert(!(p != q))
  end

  def test_from_point
    loc = @w.location
    p = Window.from_point(loc)
    assert_equal(p, @w)
    p = Window.from_point(loc.x, loc.y)
    assert_equal(p, @w)
    p.move(0, 0)
    q = Window.from_point(0, 0)
    assert_equal(p, q)
    p.move(1, 1)
    q = Window.from_point(0, 0)
    assert_not_equal(p, q)
  end

  def test_from_handle
    p = Window.from_handle(INVALID_HANDLE)
    assert_equal(nil, p)
    p = Window.from_handle(@w.handle)
    assert_equal(@w, p)
  end

  INVALID_HANDLE = -1
end
