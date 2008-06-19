require 'starling'
require "#{RAILS_ROOT}/vendor/plugins/simplified_starling/lib/simplified_starling"

namespace :simplified do

  namespace :starling do

    desc "Start starling server"
    task :start => :environment do
      starling_binary = `which starling`.strip
      options = "--config #{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml"
      command = "#{starling_binary} #{options}"
      raise RuntimeError, "Cannot find starling." if starling_binary.blank?
      system command
      Simplified::Starling.feedback("Server successfully started.")
      config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
      Simplified::Starling.prepare(config['starling']['queue'])
      Simplified::Starling.feedback("Queue #{config['starling']['queue']} successfully started.")
    end

    desc "Stop starling server"
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

    desc "Restart starling server"
    task :restart => :environment do
      Rake::Task['simplified:starling:stop'].invoke
      Rake::Task['simplified:starling:start'].invoke
    end

    desc "Server stats"
    task :stats => :environment do
      Simplified::Starling.stats
    end

  end

end