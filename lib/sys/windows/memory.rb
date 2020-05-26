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

    # The total amount of actual physical memory, in bytes.
    #
    def total
      memory['TotalPhys']
    end

    # The physical memory currently available, in bytes. This is the amount of
    # physical memory that can be immediately reused without having to write
    # its contents to disk first.
    #
    def free
      memory['AvailPhys']
    end

    # A number between 0 and 100 that specifies the approximate percentage of
    # physical memory that is in use.
    #
    def load
      memory['MemoryLoad']
    end

    module_function :memory
  end
end
