# Win32::Window
Ruby interface to the Win32 window management APIs.

## Getting Started
============
`gem install win32-window`
<br />
`require 'win32/window'`

## API
============

### Finding a window

By handle:

```ruby
w = Win32::Window.from_handle(h)
```

By screen coordinate:
```ruby
w = Win32::Window.from_point(x, y)

# Alternatively
p = Win32::Point.new(x, y)
w = Win32::Window.from_point(p)
```

By window title:
```ruby
w = Win32::Window.find(:title => /notepad$/i)
```

By process ID:
```ruby
w = Win32::Window.find(:pid => 4242)
```

The desktop window:
```ruby
w = Win32::Window.desktop
```

The foreground window:
```ruby
w = Win32::Window.foreground
```

#### Navigating the window hierarchy

#### Window properties

#### Manipulating a window

## Contributing
============

## License
============
