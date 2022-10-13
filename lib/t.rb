# File.readlines('secrets.txt').each do |line|
#   puts(line)
# end

puts File.readlines('secrets.txt')[1].split[0]

puts File.readlines('secrets.txt')[1].split[1]