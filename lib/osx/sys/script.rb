require 'awesome_print'
hash = {}
results = `vm_stat`

results.split("\n").each do |line|
  key, value = line.split(":")
  hash[key] = value.strip.delete(".").to_i
end

size = 4096
free = hash["Pages free"]
active = hash["Pages active"]
inactive = hash["Pages inactive"]
speculative = hash["Pages speculative"]
throttled = hash["Pages throttled"]
wired = hash["Pages wired down"]
purgeable = hash["Pages purgeable"]
file_backed = hash["File-backed pages"]
compressor = hash["Pages occupied by compressor"]
#compressor2 = hash["Pages stored in compressor"]

#ap hash

total = free
total = active
total += inactive
total += speculative
total += throttled
total += wired
total += purgeable
total += file_backed
total += compressor
#total += compressor2

p total * size
#ap hash
