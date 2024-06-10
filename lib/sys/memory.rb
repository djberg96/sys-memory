# frozen_string_literal: true

require 'rbconfig'
require_relative 'version'

case RbConfig::CONFIG['host_os']
  when /linux/i
    require_relative 'linux/memory'
  when /darwin|macos/i
    require_relative 'osx/memory'
  when /bsd|dragonfly/i
    require_relative 'bsd/memory'
  when /windows|win32|mingw/i
    require_relative 'windows/memory'
end
