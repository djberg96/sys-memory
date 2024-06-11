# frozen_string_literal: true

require 'ffi'

# The Sys module serves only as a namespace.
module Sys
  # The Memory module is a house for memory related singleton methods that don't require state.
  module Memory
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    attach_function :sysctlbyname, %i[string pointer pointer pointer size_t], :int

    private_class_method :sysctlbyname

    class VmTotal < FFI::Struct
      layout(
        :t_rq,     :long,   # length of the run queue
        :t_dw,     :long,   # jobs in ``disk wait'' (neg priority)
        :t_pw,     :long,   # jobs in page wait
        :t_sl,     :long,   # jobs sleeping in core
        :t_sw,     :long,   # swapped out runnable/short block jobs
        :t_vm,     :int64,  # total virtual memory
        :t_avm,    :int64,  # active virtual memory
        :t_rm,     :long,   # total real memory in use
        :t_arm,    :long,   # active real memory
        :t_vmshr,  :int64,  # shared virtual memory
        :t_avmshr, :int64,  # active shared virtual memory
        :t_rmshr,  :long,   # shared real memory
        :t_armshr, :long,   # active shared real memory
        :t_free,   :long    # free memory pages
      )
    end

    class VmStats < FFI::Struct
      layout(
        :v_page_size, :uint,
        :v_unused01, :uint,
        :v_page_count, :long,
        :v_free_severe, :long,
        :v_free_reserved, :long,
        :v_free_min, :long,
        :v_free_target, :long,
        :v_inactive_target, :long,
        :v_paging_wait, :long,
        :v_paging_start, :long,
        :v_paging_target1, :long,
        :v_paging_target2, :long,
        :v_pageout_free_min, :long,
        :v_interrupt_free_min, :long,
        :v_dma_pages, :long,
        :v_unused_fixed01, :long,
        :v_unused_fixed02, :long,
        :v_unused_fixed03, :long,
        :v_free_count, :long,
        :v_wire_count, :long,
        :v_active_count, :long,
        :v_inactive_count, :long,
        :v_cache_count, :long,
        :v_dma_avail, :long,
        :v_unused_variable, [:long, 9]
      )
    end

    private_constant :VmStats

    # Obtain detailed memory information about your host in the form of a hash.
    # Note that the exact nature of this hash is largely dependent on your
    # operating system.
    #
    def memory
      hash = {}

      begin
        optr = FFI::MemoryPointer.new(:uint64_t)
        size = FFI::MemoryPointer.new(:size_t)
        size.write_int(optr.size)

        if sysctlbyname('hw.physmem', optr, size, nil, 0) < 0
          raise SystemCallError.new('sysctlbyname', FFI.errno)
        end

        hash[:total] = optr.read_uint64
      ensure
        optr.free if optr && !optr.null?
        size.clear
      end

      hash
    end

    # Total memory in bytes. By default this is only physical memory, but
    # if the +extended+ option is set to true, then swap memory is included as
    # part of the total.
    #
    def total(extended: false)
      hash = memory
      extended ? hash[:total] + hash[:swap_total] : hash[:total]
    end

    # The memory currently available, in bytes. By default this is only
    # physical memory, but if the +extended+ option is set to true, then free
    # swap memory is also included.
    #
    def free(extended: false)
      hash = memory
      extended ? hash[:free] + hash[:swap_available] : hash[:free]
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
  end
end

p Sys::Memory.memory
