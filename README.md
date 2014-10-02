# Win32::Window
Ruby interface to the Win32 window management APIs.

## Getting Started

`gem install win32-window --pre`
<br />
`require 'win32/window'`
<br />
`include Win32` (optional)

## API

### Finding a window

*By handle.* If the handle does not refer to a window, `nil` is returned.

```ruby
w = Window.from_handle(h)
```

*By screen coordinates.* Returns the top-level window covering the specified coordinates.
```ruby
w = Window.from_point(x, y)

# Alternatively:
p = Point.new(x, y)
w = Window.from_point(p)
```

*By window title.* Returns all top-level windows whose title matches the specified regex. This can return multiple windows.
```ruby
w = Window.find(:title => /calculator/i)

# Get just the first result.
w = Window.find(:title => /Google Chrome$/).first
```

*By process ID.* Returns all top-level windows owned by the specified process ID. This can return multiple windows.
```ruby
w = Window.find(:pid => 4242)
```

*By custom filter.* Returns all top-level windows for which the block holds true. This can return multiple windows.
```ruby
w = Window.find { |pid, title|
  (pid > 1000) && (title.end_with? 'Notepad')
}
```

*The desktop window.* Note that the geometry of this window corresponds to the primary monitor only.
```ruby
w = Window.desktop
```

*The foreground window.* This is the window with which the user is currently working.
```ruby
w = Window.foreground
```

#### Navigating the window hierarchy

`w.parent`

`w.child_of?`

#### Basic properties

`w.handle`

`w.title`

`w.pid`

#### Geometry

`w.size` ...

`w.client.size` ...

`w.resize(...)`

`w.move(...)`

#### Display

`w.minimized?`, `w.minimize`

`w.maximized?`, `w.maximize`

`w.foreground?`, `w.foregroundize`

`w.restore`

`w.visible?`, `w.hide`, `w.show`

`w.topmost?`, `w.topmost=`

## License

Copyright &copy; 2013 Chris Schmich
<br />
MIT License. See [LICENSE](LICENSE) for details.
