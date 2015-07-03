#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "production"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exist?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

@running = true
Signal.trap("TERM") do 
  @running = false
end

# rubocop: disable Style/WhileUntilDo
while @running do
end
