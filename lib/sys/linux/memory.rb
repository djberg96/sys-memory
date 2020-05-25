module Sys
  module Memory
    MEMORY_FILE = '/proc/meminfo'

    def memory
      hash = {}
      regex = /(.*)?:\s+?(\d+)/

      IO.foreach(MEMORY_FILE) do |line|
        #p line
        key, value = regex.match(line.chomp).captures
        hash[key] = value.to_i
      end

      hash
    end

    module_function :memory
  end
end
