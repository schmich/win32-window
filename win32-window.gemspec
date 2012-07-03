Gem::Specification.new do |s|
  s.name = 'win32-window'
  s.version = eval(File.read('lib/win32/window/version.rb'))
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Ruby interface to the Win32 window management APIs.'
  s.description = <<-END
    A Ruby library to work with Microsoft Windows' Win32 window management APIs,
    including search, enumeration, and window manipulation.
  END
  s.authors = ['Chris Schmich']
  s.email = 'schmch@gmail.com'
  s.files = Dir['{lib}/**/*.rb', 'bin/*', '*.md']
  s.require_path = 'lib'
  s.homepage = 'https://github.com/schmich/win32-window'
  s.add_development_dependency 'rake', '>= 0.9.2.2'
end
