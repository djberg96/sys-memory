module Sys
  module Memory
    require 'ffi'
    extend FFI::Library
    ffi_lib 'kernel32'

    typedef :uint32, :dword
    typedef :uint64, :dwordlong

    class MemoryStatusEx < FFI::Struct
      layout(
        :dwLength, :dword,
        :dwMemoryLoad, :dword,
        :ullTotalPhys, :dwordlong,
        :ullAvailPhys, :dwordlong,
        :ullTotalPageFile, :dwordlong,
        :ullAvailPageFile, :dwordlong,
        :ullTotalVirtual, :dwordlong,
        :ullAvailVirtual, :dwordlong,
        :ullAvailExtendedVirtual, :dwordlong
      )
    end

    attach_function :GlobalMemoryStatusEx, [MemoryStatusEx], :bool

    def memory
      struct = MemoryStatusEx.new
      struct[:dwLength] = struct.size

      unless GlobalMemoryStatusEx(struct)
        raise SystemCallError.new(FFI.errno)
      end

      hash = {}

      struct.members.each do |member|
        key = member.to_s.sub(/^ull|^dw/, '')
        hash[key] = struct[member]
      end

      hash.delete('Length')
      hash
    end

    module_function :memory
  end
end

p Sys::Memory.memory
