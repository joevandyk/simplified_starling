require 'starling'
require "#{RAILS_ROOT}/vendor/plugins/simplified_starling/lib/simplified_starling"

namespace :simplified do

  namespace :starling do

    def starling_running?
      config = YAML.load_file("#{RAILS_ROOT}/config/starling.yml")[RAILS_ENV]
      if File.exist?(config['pid_file']) 
        Process.getpgid(File.read(config['pid_file']).to_i) rescue return false
        else
          return true
        end
    end

    desc "Start starling server"
    task :start do
      config = YAML.load_file("#{RAILS_ROOT}/config/starling.yml")[RAILS_ENV]
      unless starling_running?
        starling_binary = `which starling`.strip
        raise RuntimeError, "Cannot find starling" if starling_binary.blank?
        options = []
        options << "--queue_path #{config['queue_path']}"
        options << "--host #{config['host']}"
        options << "--port #{config['port']}"
        options << "-d" if config['daemonize']
        options << "--pid #{config['pid_file']}"
        options << "--syslog #{config['syslog_channel']}"
        options << "--timeout #{config['timeout']}"
        system "#{starling_binary} #{options.join(' ')}"
        Simplified::Starling.feedback("Starling successfully started")
      else
        Simplified::Starling.feedback("Starling is already running")
      end
    end

    desc "Stop starling server"
    task :stop do
      config = YAML.load_file("#{RAILS_ROOT}/config/starling.yml")[RAILS_ENV]
      pid_file = config['pid_file']
      if File.exist?(pid_file)
        system "kill -9 `cat #{pid_file}`"
        Simplified::Starling.feedback("Starling successfully stopped")
        File.delete(pid_file)
      else
        Simplified::Starling.feedback("Starling is not running")
      end
    end

    desc "Restart starling server"
    task :restart do
      config = YAML.load_file("#{RAILS_ROOT}/config/starling.yml")
      pid_file = config['pid_file']
      Rake::Task['simplified:starling:stop'].invoke if File.exist?(pid_file)
      Rake::Task['simplified:starling:start'].invoke
    end

    desc "Start processing jobs (process is daemonized)"
    task :start_processing_jobs => :environment do
      begin
        pid_file = "#{RAILS_ROOT}/tmp/pids/starling_#{RAILS_ENV}.pid"
        unless File.exist?(pid_file)
          Simplified::Starling.stats
          config = YAML.load_file("#{RAILS_ROOT}/config/starling.yml")[RAILS_ENV]
          Simplified::Starling.process(config['queue'])
          Simplified::Starling.feedback("Started processing jobs")
        else
          Simplified::Starling.feedback("Jobs are already being processed")
        end
      rescue Exception => error
        Simplified::Starling.feedback(error.message)
      end
    end

    desc "Stop processing jobs"
    task :stop_processing_jobs do
      pid_file = "#{RAILS_ROOT}/tmp/pids/starling_#{RAILS_ENV}.pid"
      if File.exist?(pid_file)
        system "kill -9 `cat #{pid_file}`"
        Simplified::Starling.feedback("Stopped processing jobs")
        File.delete(pid_file)
      else
        Simplified::Starling.feedback("Jobs is not being processed")
      end
    end

    desc "Start starling and process jobs"
    task :start_and_process_jobs do
      Rake::Task['simplified:starling:start'].invoke
      sleep 10
      Rake::Task['simplified:starling:start_processing_jobs'].invoke
    end

    desc "Server stats"
    task :stats do
      begin
        queue, items = Simplified::Starling.stats
        Simplified::Starling.feedback("Queue has #{items} jobs")
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
