#!/usr/bin/env ruby

require 'fileutils'

PROJECT_NAME = %x[basename $(git rev-parse --show-toplevel)].strip()
PREFIX = "https://github.com/takezoe/#{PROJECT_NAME}"
RELEASE_NOTES_FILE = "RELEASE_NOTES.md"

next_tag = ARGV[0]
next_version = next_tag.sub("v", "")
puts "next version: #{next_version}"

last_tag = `git describe --tags --abbrev=0 #{next_tag}^`.chomp
last_version = last_tag.sub("v", "")
puts "last version: #{last_version}"

abort("Can't use empty version string") if next_version.empty?

logs = `git log #{last_tag}..HEAD --pretty=format:'%h %s'`
# Add links to GitHub issues
logs = logs.gsub(/\#([0-9]+)/, "[#\\1](#{PREFIX}/issues/\\1)")

new_release_notes = []
new_release_notes <<= "\#\# #{next_version}\n"
new_release_notes <<= logs.split(/\n/)
  .reject{|line| line.include?("#{last_version} release notes")}
  .map{|x|
    rev = x[0..6]
    "- #{x[8..-1]} [[#{rev}](#{PREFIX}/commit/#{rev})]\n"
  }

release_notes = []
notes = File.readlines(RELEASE_NOTES_FILE)

release_notes <<= notes[0..1]
release_notes <<= new_release_notes
release_notes <<= "\n"
release_notes <<= notes[2..-1]

Dir.mkdir('target')
TMP_RELEASE_NOTES_FILE = "target/#{RELEASE_NOTES_FILE}.tmp"
File.delete(TMP_RELEASE_NOTES_FILE) if File.exists?(TMP_RELEASE_NOTES_FILE)
File.write("#{TMP_RELEASE_NOTES_FILE}", release_notes.join)

FileUtils.cp(TMP_RELEASE_NOTES_FILE, RELEASE_NOTES_FILE)
File.delete(TMP_RELEASE_NOTES_FILE)
