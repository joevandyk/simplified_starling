require 'starling'
require "#{RAILS_ROOT}/vendor/plugins/simplified_starling/lib/simplified_starling"

namespace :simplified do

  namespace :starling do

    desc "Start Starling server"
    task :start => :environment do
      starling_binary = `which starling`.strip
      options = "--config #{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml"
      command = "#{starling_binary} #{options}"
      raise RuntimeError, "Cannot find starling." if starling_binary.blank?
      system command
      Simplified::Starling.feedback("Server successfully started.")
    end

    desc "Stop Starling server"
    task :stop => :environment do
      config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
      pid_file = config['starling']['pid_file']
      if File.exist?(pid_file)
        system "kill -9 `cat #{config['starling']['pid_file']}`"
        Simplified::Starling.feedback("Server successfully stopped.")
      else
        Simplified::Starling.feedback("Server is not running.")
      end
      system "rm #{pid_file}"
    end

    desc "Queue Status"
    task :queues => :environment do
      begin
        items = STARLING.sizeof(:all)
        if items.empty?
          Simplified::Starling.feedback("Queue is empty.")
        else
          message = []
          items.each { |key, value| message << "#{key}: #{value}" }
          Simplified::Starling.feedback(message.join(" / "))
        end
      rescue Exception => error
        Simplified::Starling.feedback(error)
      end
    end

    desc "Processor ..."
    task :start_processor => :environment do
      if ENV['QUEUE']
        pid_file = "#{RAILS_ROOT}/log/starling_#{ENV['QUEUE']}_#{RAILS_ENV}.pid"
        if File.exist?(pid_file)
          Simplified::Starling.feedback("#{ENV['QUEUE']} already running.")
          exit
        end
        Simplified::Starling.feedback("Queue processor started for #{ENV['QUEUE']}.")
        Simplified::Starling.prepare(ENV['QUEUE'])
      else
        Simplified::Starling.feedback("Please, provide a queue name with ENV['QUEUE']")
      end
    end

    desc "Stop Processor"
    task :stop_processor => :environment do
      if ENV['QUEUE']
        pid_file = "#{RAILS_ROOT}/log/starling_#{ENV['QUEUE']}_#{RAILS_ENV}.pid"
        if File.exist?(pid_file)
          pid = File.read(pid_file).chomp
          system "kill #{pid}"
          FileUtils.rm(pid_file)
          Simplified::Starling.feedback("Queue processor stopped.")
        else
          Simplified::Starling.feedback("Pid file for #{ENV['QUEUE']} doesn't exist.")
        end
      else
        Simplified::Starling.feedback("Please, provide a queue name with ENV['QUEUE']")
      end
    end

    ##
    # This is used for testing purposes ...

    task :push do
      starling = Starling.new('127.0.0.1:22122')
      starling.set("newsletter", { :type => 'newsletter', :id => 1, :task => 'test' })
      starling.set("newsletter", { :type => 'newsletter', :id => 1, :task => 'deliver' })
      starling.set("comment", { :type => 'comment', :id => 1500, :task => 'check_if_spam' })
    end

    ##
    # And so is this ...

    task :pop do
      starling = Starling.new('127.0.0.1:22122')
      starling.get("newsletter")
      starling.get("comment")
    end

    task :test, :queues do |task, args|
      if args[:queues].is_a? String
        puts args[:queues].split.join(", ")
      else
        Simplified::Starling.feedback("Please, provide a queue name.")
      end
    end

  end

end