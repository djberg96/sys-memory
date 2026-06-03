# frozen_string_literal: true

require 'ffi'

# The Sys module serves only as a namespace.
module Sys
  # The Memory module is a house for memory related singleton methods that don't require state.
  module Memory
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    attach_function :sysctlbyname, %i[string pointer pointer pointer size_t], :int

    if RbConfig::CONFIG['host_os'] =~ /freebsd/i
      ffi_lib FFI::Library::LIBC, FFI.map_library_name('kvm')

      attach_function :kvm_openfiles, %i[string string string int pointer], :pointer
      attach_function :kvm_geterr, [:pointer], :string
      attach_function :kvm_getswapinfo, %i[pointer pointer int int], :int
      attach_function :kvm_close, [:pointer], :int

      # Private class wrapper for struct kvm_swap
      class KvmSwap < FFI::Struct
        layout(
          :ksw_devname, [:char, 32],
          :ksw_used, :uint,
          :ksw_total, :uint,
          :ksw_flags, :int,
          :ksw_reserved1, :uint,
          :ksw_reserved2, :uint
        )
      end

      private_constant :KvmSwap
    end

    # Obtain detailed memory information about your host in the form of a hash.
    # Note that the exact nature of this hash is largely dependent on your
    # operating system.
    #
    def memory
      page_size = get_by_name('hw.pagesize')

      hash = {}
      hash[:total] = get_by_name('hw.physmem')
      hash[:active] = get_by_name('vm.stats.vm.v_active_count') * page_size
      hash[:all] = get_by_name('vm.stats.vm.v_page_count') * page_size
      hash[:cache] = get_by_name('vm.stats.vm.v_cache_count') * page_size
      hash[:free] = get_by_name('vm.stats.vm.v_free_count') * page_size
      hash[:inactive] = get_by_name('vm.stats.vm.v_inactive_count') * page_size
      hash[:wire] = get_by_name('vm.stats.vm.v_wire_count') * page_size

      if RbConfig::CONFIG['host_os'] =~ /dragonfly/i
        hash[:swap_size] = get_by_name('vm.swap_size')
        hash[:swap_free] = get_by_name('vm.swap_free')
      elsif RbConfig::CONFIG['host_os'] =~ /freebsd/i
        hash[:swap_size] = get_by_name('vm.swap_total')
        hash[:swap_free] = hash[:swap_size] - get_freebsd_swap_used(page_size)
      else
        hash[:swap_size] = get_by_name('vm.swap_total')
        hash[:swap_free] = hash[:swap_size] - get_by_name('vm.swap_reserved') # Best guess
      end

      hash[:available] = hash[:free] + hash[:inactive] + hash[:cache]

      hash
    end

    # Total memory in bytes. By default this is only physical memory, but
    # if the +extended+ option is set to true, then swap memory is included as
    # part of the total.
    #
    def total(extended: false)
      hash = memory
      extended ? hash[:total] + hash[:swap_size] : hash[:total]
    end

    # The memory currently available, in bytes. By default this is only
    # physical memory, but if the +extended+ option is set to true, then free
    # swap memory is also included.
    #
    def free(extended: false)
      hash = memory
      extended ? hash[:free] + hash[:swap_free] : hash[:free]
    end

    # The memory currently available, in bytes. This includes free memory and
    # inactive/cache pages that the system can reclaim.
    # If the +extended+ option is set to true, then free swap memory is also
    # included.
    #
    def available(extended: false)
      hash = memory
      available = hash[:available]

      extended ? available + hash[:swap_free] : available
    end

    # The memory, in bytes, currently in use. By default this is only
    # physical memory, but if the +extended+ option is set to true then
    # swap is included in the calculation.
    #
    def used(extended: false)
      total(extended: extended) - free(extended: extended)
    end

    # A number between 0 and 100 that specifies the approximate percentage of
    # memory that is in use. If the +extended+ option is set to true then
    # swap memory is included in the calculation.
    #
    def load(extended: false)
      (used(extended: extended) / total(extended: extended).to_f).round(2) * 100
    end

    module_function :memory, :total, :free, :available, :load, :used

    private

    def get_by_name(mib)
      value = nil

      begin
        optr = FFI::MemoryPointer.new(:uint64_t)
        size = FFI::MemoryPointer.new(:size_t)
        size.write_int(optr.size)

        if sysctlbyname(mib, optr, size, nil, 0) < 0
          raise SystemCallError.new("sysctlbyname: #{mib}", FFI.errno)
        end

        value = optr.read_uint64
      ensure
        optr.free if optr && !optr.null?
        size.free if size && !size.null?
      end

      value
    end

    def get_freebsd_swap_used(page_size)
      kd = nil

      begin
        error = FFI::MemoryPointer.new(:char, 2048)
        kd = kvm_openfiles(nil, File::NULL, nil, 0, error)

        if kd.null?
          message = error.read_string
          raise SystemCallError, "kvm_openfiles: #{message.empty? ? 'unknown error' : message}"
        end

        swap = KvmSwap.new

        if kvm_getswapinfo(kd, swap.pointer, 1, 0) < 0
          raise SystemCallError, "kvm_getswapinfo: #{kvm_geterr(kd)}"
        end

        swap[:ksw_used] * page_size
      ensure
        kvm_close(kd) if kd && !kd.null?
        error.free if error && !error.null?
      end
    end

    module_function :get_by_name, :get_freebsd_swap_used
  end
end
