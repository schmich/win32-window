# Win32::Window
Ruby interface to the Win32 window management APIs.

## Getting Started
============
`gem install win32-window`
<br />
`require 'win32/window'`
<br />
`include Win32` (optional)

## API
============

### Finding a window

By handle:

```ruby
w = Window.from_handle(h)
```

By screen coordinate:
```ruby
w = Window.from_point(x, y)

# Alternatively
p = Point.new(x, y)
w = Window.from_point(p)
```

By window title:
```ruby
w = Window.find(:title => /notepad$/i)
```

By process ID:
```ruby
w = Window.find(:pid => 4242)
```

The desktop window:
```ruby
w = Window.desktop
```

The foreground window:
```ruby
w = Window.foreground
```

#### Navigating the window hierarchy

#### Window properties

#### Manipulating a window

## Contributing
============

## License
============
