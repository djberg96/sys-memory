# frozen_string_literal: true

# The Sys module serves as a namespace only.
module Sys
  # The Memory module provides various functions that return information
  # regarding the memory on your system.
  module Memory
    require 'ffi'
    extend FFI::Library
    ffi_lib 'kernel32'

    typedef :uint32, :dword
    typedef :uint64, :dwordlong

    # Private wrapper class for the MEMORYSTATUSEX struct
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

    private_constant :MemoryStatusEx

    attach_function :GlobalMemoryStatusEx, [MemoryStatusEx], :bool
    private_class_method :GlobalMemoryStatusEx

    ffi_lib 'psapi'

    # Private wrapper class for the PERFORMANCE_INFORMATION struct
    class PerformanceInformation < FFI::Struct
      layout(
        :cb, :dword,
        :CommitTotal, :size_t,
        :CommitLimit, :size_t,
        :CommitPeak, :size_t,
        :PhysicalTotal, :size_t,
        :PhysicalAvailable, :size_t,
        :SystemCache, :size_t,
        :KernelTotal, :size_t,
        :KernelPaged, :size_t,
        :KernelNonpaged, :size_t,
        :PageSize, :size_t,
        :HandleCount, :dword,
        :ProcessCount, :dword,
        :ThreadCount, :dword
      )
    end

    private_constant :PerformanceInformation

    attach_function :GetPerformanceInfo, [PerformanceInformation, :dword], :bool
    private_class_method :GetPerformanceInfo

    # Obtain detailed memory information about your host in the form of a hash.
    # Note that the exact nature of this hash is largely dependent on your
    # operating system.
    #
    def memory
      struct = MemoryStatusEx.new
      struct[:dwLength] = struct.size

      unless GlobalMemoryStatusEx(struct)
        raise SystemCallError.new('GlobalMemoryStatusEx', FFI.errno)
      end

      hash = {}

      struct.members.each do |member|
        key = member.to_s.sub(/^ull|^dw/, '')
        hash[key] = struct[member]
      end

      hash.delete('Length')

      perf = PerformanceInformation.new

      unless GetPerformanceInfo(perf, perf.size)
        raise SystemCallError.new('GetPerformanceInfo', FFI.errno)
      end

      perf.members.each do |member|
        key = member.to_s
        hash[key] = perf[member]
      end

      hash.delete('cb')

      hash
    end

    # Total memory in bytes. By default this is only physical memory, but
    # if the +extended+ option is set to true then swap (pagefile) memory is
    # included as part of the total.
    #
    def total(extended: false)
      hash = memory
      extended ? hash['TotalPhys'] + hash['TotalPageFile'] : hash['TotalPhys']
    end

    # The physical memory currently available, in bytes. This is the amount of
    # physical memory that can be immediately reused without having to write
    # its contents to disk first.
    #
    # If the +extended+ option is set to true then available swap (pagefile)
    # memory is included as part of the total.
    #
    def free(extended: false)
      hash = memory
      extended ? hash['AvailPhys'] + hash['AvailPageFile'] : hash['AvailPhys']
    end

    # The memory, in bytes, currently in use. By default this is only
    # physical memory, but if the +extended+ option is set to true then
    # swap (pagefile) is included in the calculation.
    #
    def used(extended: false)
      total(extended: extended) - free(extended: extended)
    end

    # A number between 0 and 100 that specifies the approximate percentage of
    # physical memory that is in use.
    #
    # On MS Windows the +extended+ option is ignored, but present for interface
    # compatibility with other platforms.
    #
    def load(_extended: false)
      memory['MemoryLoad']
    end

    module_function :memory, :total, :free, :load, :used
  end
end
