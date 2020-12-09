#!/usr/bin/env ruby

last_tag = `git describe --tags --abbrev=0`.chomp
last_version = last_tag.sub("v", "")
puts "last version: #{last_version}"

print "next version? "
next_version = STDIN.gets.chomp

abort("Can't use empty version string") if next_version.empty?

def run(cmd)
  puts cmd
  system cmd
end

run "git tag v#{next_version}"
run "git push origin v#{next_version}"
