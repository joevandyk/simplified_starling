require 'starling'
require "#{RAILS_ROOT}/vendor/plugins/simplified_starling/lib/simplified_starling"

namespace :simplified do

  namespace :starling do

    desc "Start starling server"
    task :start => :environment do

      config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
      pid_file = config['starling']['pid_file']

      unless File.exist?(pid_file)
        starling_binary = `which starling`.strip
        options = "--config #{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml"
        command = "#{starling_binary} #{options}"
        raise RuntimeError, "Cannot find starling" if starling_binary.blank?
        system command
        Simplified::Starling.feedback("Starling successfully started")
      else
        Simplified::Starling.feedback("Starling is already running")
      end

    end

    desc "Stop starling server"
    task :stop => :environment do

      config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
      pid_file = config['starling']['pid_file']

      if File.exist?(pid_file)
        system "kill -9 `cat #{config['starling']['pid_file']}`"
        Simplified::Starling.feedback("Starling successfully stopped")
        File.delete(pid_file)
      else
        Simplified::Starling.feedback("Starling is not running")
      end

    end

    desc "Restart starling server"
    task :restart => :environment do

      config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
      pid_file = config['starling']['pid_file']

      Rake::Task['simplified:starling:stop'].invoke if File.exist?(pid_file)
      Rake::Task['simplified:starling:start'].invoke

    end

    desc "Start processing queue and daemonize"
    task :start_processing_queue => :environment do
      begin
        pid_file = "#{RAILS_ROOT}/tmp/pids/starling_#{RAILS_ENV}.pid"
        unless File.exist?(pid_file)
          Simplified::Starling.stats
          config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
          Simplified::Starling.process(config['starling']['queue'])
          Simplified::Starling.feedback("Started processing queue")
        else
          Simplified::Starling.feedback("Queue is already being processed")
        end
      rescue Exception => error
        Simplified::Starling.feedback(error.message)
      end
    end

    desc "Stop processing queue"
    task :stop_processing_queue => :environment do
      pid_file = "#{RAILS_ROOT}/tmp/pids/starling_#{RAILS_ENV}.pid"
      if File.exist?(pid_file)
        system "kill -9 `cat #{pid_file}`"
        Simplified::Starling.feedback("Stopped processing queue")
        File.delete(pid_file)
      else
        Simplified::Starling.feedback("Queue is not being processed")
      end
    end

    desc "Start starling and process queue"
    task :start_and_process => :environment do
      Rake::Task['simplified:starling:start'].invoke
      sleep 10
      Rake::Task['simplified:starling:start_processing_queue'].invoke
    end

    desc "Server stats"
    task :stats => :environment do
      begin
        queue, items = Simplified::Starling.stats
        Simplified::Starling.feedback("Queue has #{items} jobs.")
      rescue Exception => error
        Simplified::Starling.feedback(error.message)
      end
    end

    desc "Copy config files to config/starling/*"
    task :setup do
      Simplified::Starling.setup
    end

  end

end