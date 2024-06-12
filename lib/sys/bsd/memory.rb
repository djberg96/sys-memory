# frozen_string_literal: true

require 'ffi'

# The Sys module serves only as a namespace.
module Sys
  # The Memory module is a house for memory related singleton methods that don't require state.
  module Memory
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    attach_function :sysctlbyname, %i[string pointer pointer pointer size_t], :int

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
      hash[:swap_size] = get_by_name('vm.swap_size')
      hash[:swap_free] = get_by_name('vm.swap_free')

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

    module_function :memory, :total, :free, :load, :used

    private

    def get_by_name(mib)
      value = nil

      begin
        optr = FFI::MemoryPointer.new(:uint64_t)
        size = FFI::MemoryPointer.new(:size_t)
        size.write_int(optr.size)

        if sysctlbyname(mib, optr, size, nil, 0) < 0
          raise SystemCallError.new('sysctlbyname', FFI.errno)
        end

        value = optr.read_uint64
      ensure
        optr.free if optr && !optr.null?
        size.free if size && !size.null?
      end

      value
    end

    module_function :get_by_name
  end
end
