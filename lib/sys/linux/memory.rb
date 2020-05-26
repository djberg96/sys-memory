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

    # Total available physical memory.
    #
    def total
      memory['MemTotal'] * 1024
    end

    def free
      memory['MemFree'] * 1024
    end

    def used
      hash = memory
      (hash['MemTotal'] - hash['MemFree'] - hash['Buffers'] - hash['Cached'] - hash['Slab']) * 1024
    end

    def load
      (used / total.to_f).round(2) * 100
    end

    module_function :memory, :total, :free, :used, :load
  end
end
