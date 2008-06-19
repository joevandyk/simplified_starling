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

    desc "Queue status"
    task :queues => :environment do
      begin
        items = STARLING.sizeof(:all)
        if items.empty?
          Simplified::Starling.feedback("No queues available.")
        else
          message = []
          items.each { |key, value| message << "#{key}[#{value}]" }
          Simplified::Starling.feedback(message.join(", "))
        end
      rescue Exception => error
        Simplified::Starling.feedback(error)
      end
    end

    ##
    # This is used for testing purposes ...

    task :push do
      starling = Starling.new('127.0.0.1:22122')
      starling.set("newsletters", { :type => 'newsletter', :id => 1, :task => 'deliver' })
      starling.set("comments", { :type => 'comment', :id => 1500, :task => 'check_if_spam' })
      Simplified::Starling.feedback("Pushed a `newsletter` and a `comments` job.")
    end

    task :pop do
      starling = Starling.new('127.0.0.1:22122')
      starling.get("newsletters")
      starling.get("comments")
      Simplified::Starling.feedback("Popped a `newsletter` and a `comments` job.")
    end

    namespace :queues do

      desc "Start a queue."
      task :start => :environment do
        if ENV['QUEUE']
          Simplified::Starling.prepare(ENV['QUEUE'])
        else
          Simplified::Starling.feedback("Please, provide a queue name with QUEUE=name")
        end
      end

      desc "Stop a queue."
      task :stop => :environment do
        if ENV['QUEUE']
          pid = `ps aux | grep 'simplified:starling:start_processor QUEUE=#{ENV['QUEUE']}' | grep -v grep | ruby -e 'puts STDIN.read.split[1]'`
          unless pid == "nil\n"
            system "kill #{pid}"
            Simplified::Starling.feedback("Queue processor stopped for `#{ENV['QUEUE']}`.")
          else
            Simplified::Starling.feedback("Queue `#{ENV['QUEUE']}` is not running.")
          end
        else
          Simplified::Starling.feedback("Please, provide a queue name with QUEUE=name")
        end
      end

      desc "Restart a queue."
      task :restart => :environment do
        if ENV['QUEUE']
          Rake::Task['simplified:starling:queues:stop'].invoke
          Rake::Task['simplified:starling:queues:start'].invoke
        else
          Simplified::Starling.feedback("Please, provide a queue name with QUEUE=name")
        end
      end

    end

  end

end