require 'Qt4'
require 'win32/semaphore'
require_relative 'shared'

Qt::Application.new(ARGV) do
  Qt::Widget.new do
    self.window_title = $title
    resize(320, 200)

    button = Qt::PushButton.new('Quit') do
      connect(SIGNAL :clicked) { Qt::Application.instance.quit }
    end

    label = Qt::Label.new('win32-window')

    self.layout = Qt::VBoxLayout.new do
      add_widget(label, 0, Qt::AlignCenter)
      add_widget(button, 0, Qt::AlignRight)
    end

    def show
      super

      begin
        semaphore = Win32::Semaphore.open($semaphore)
        semaphore.release(1)
      rescue Win32::Semaphore::Error
        # Ignore if we can't release.
      end
    end

    show
  end

  exec
end
