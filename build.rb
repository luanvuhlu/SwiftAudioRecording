#!/usr/bin/env ruby -wU

###################################################################
# build AudioRecord
###################################################################

require 'open3'
require 'fileutils'
require 'pathname'
require 'rexml/document'
include REXML

# This finds our current directory, to generate an absolute path for the require
libdir = "."
Dir.chdir libdir        # change to libdir so that requires work

if(ARGV.length != 1)
  puts "usage: "
  puts "build.rb <required:configuration (Development|Deployment)>"
  exit 0;
end

configuration = ARGV[0]
out = nil
err = nil

@svn_root = "."
@source = "#{@svn_root}"


configuration = "Development" if configuration == "dev"
configuration = "Deployment" if configuration == "dep"

`sudo rm -rf #{@svn_root}/Build/InstallerRoot`

###################################################################

puts "  Building the new AudioRecord.app with Xcode"

Dir.chdir("#{@source}")
Open3.popen3("xcodebuild -project AudioRecord.xcodeproj -target AudioRecord -configuration #{configuration} clean build") do |stdin, stdout, stderr|
  out = stdout.read
  err = stderr.read
end


if /BUILD SUCCEEDED/.match(out)
  puts "    BUILD SUCCEEDED"
else
  puts "    BUILD FAILED"
end


###################################################################

puts "  Done."
puts ""
exit 0

