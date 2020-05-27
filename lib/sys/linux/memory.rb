module Sys
  module Memory
    MEMORY_FILE = '/proc/meminfo'

    def memory
      hash = {}
      regex = /(.*)?:\s+?(\d+)/

      IO.foreach(MEMORY_FILE) do |line|
        key, value = regex.match(line.chomp).captures
        hash[key] = value.to_i
      end

      hash
    end

    # Total memory in bytes. By default this is only physical memory, but
    # if the +extended+ option is set to true, then swap memory is included
    # as part of the total.
    #
    def total(extended: false)
      hash = memory
      extended ? (hash['MemTotal'] + hash['SwapTotal']) * 1024 : hash['MemTotal'] * 1024
    end

    # The memory currently available, in bytes. By default this is only
    # physical memory, but if the +extended+ option is set to true, then free
    # swap memory is also included.
    #
    def free(extended: false)
      hash = memory
      extended ? (hash['MemFree'] + hash['SwapFree']) * 1024 : hash['MemFree'] * 1024
    end

    # The memory, in bytes, currently in use. By default this is only
    # physical memory, but if the +extended+ option is set to true then
    # swap is included in the calculation.
    #
    def used(extended: false)
      hash = memory
      (total(extended) - free(extended) - hash['Buffers'] - hash['Cached'] - hash['Slab']) * 1024
    end

    # A number between 0 and 100 that specifies the approximate percentage of
    # memory that is in use. If the +extended+ option is set to true then
    # swap memory is included in the calculation.
    #
    def load(extended: false)
      (used(extended) / total(extended).to_f).round(2) * 100
    end

    module_function :memory, :total, :free, :used, :load
  end
end
