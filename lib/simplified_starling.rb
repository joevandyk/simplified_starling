#!/usr/bin/env ruby

##
# Boot Rails
#
require File.dirname(__FILE__) + '/../../../../config/environment'

require 'rubygems'
require 'starling'

unless ARGV.size == 1
  puts "== STARLING ERROR ========================================"
  puts "=> Please, provide a queue name."
  exit
end

##
# Connect to Starling to check if the queue exists or not ...
#

def start_processing(queue)
  pid = fork do
    Signal.trap('HUP', 'IGNORE') # Don't die upon logout
    loop do
      job = STARLING.get(queue)
      begin
        job[:type].constantize.find(job[:id]).send(job[:task])
      rescue
        puts "Error on #{job}"
      end
      # sleep 5
    end
  end
  Process.detach(pid)
end

begin
  STARLING = Starling.new('127.0.0.1:22122')
  puts STARLING.available_queues.inspect
  if STARLING.available_queues.include?(ARGV.first)
    puts "== STARTING STARLING PROCESSOR ==========================="
    start_processing(ARGV.first)
  else
    puts "== STARLING ERROR: Queue not available ==================="
  end
rescue Exception => error
  puts "== STARLING ERROR: #{error} ==============="
end