require 'rbconfig'

case RbConfig::CONFIG['host_os']
  when /linux/i
    require_relative 'linux/memory'
  when /darwin|macos/i
    require_relative 'osx/memory'
  when /windows|win32|mingw/i
    require_relative 'windows/memory'
end
