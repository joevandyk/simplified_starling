module Simplified

  class Starling

    def self.prepare(queue)
      self.feedback("Queue processor started for `#{queue}`.")
      start_processing(queue)
    end

    def self.process(queue, daemonize = true)

      pid = fork do
        Signal.trap('HUP', 'IGNORE') # Don't die upon logout
        loop { pop(queue) }
      end

      if daemonize

        ##
        # Write pid file in pid folder
        #
        File.open("#{RAILS_ROOT}/tmp/pids/starling_#{RAILS_ENV}.pid", "w") do |pid_file|
          pid_file.puts pid
        end

        ##
        # Detach process
        #
        Process.detach(pid)

      end

    end

    def self.pop(queue)
      logger = Logger.new("#{RAILS_ROOT}/log/starling_#{RAILS_ENV}.log")
      job = STARLING.get(queue)
      begin
        if job[:id]
          job[:type].constantize.find(job[:id]).send(job[:task])
        else
          job[:type].constantize.send(job[:task])
        end
        logger.info "[#{Time.now.to_s(:db)}] Popped #{job[:task]} on #{job[:type]} #{job[:id]}"
      rescue ActiveRecord::RecordNotFound
        logger.warn "[#{Time.now.to_s(:db)}] WARNING #{job[:type]}##{job[:id]} gone from database."
      rescue ActiveRecord::StatementInvalid
        logger.warn "[#{Time.now.to_s(:db)}] WARNING Database connection gone, reconnecting & retrying."
        logger.info "                        #{job.inspect}"
        ActiveRecord::Base.connection.reconnect! and retry
      rescue Exception => error
        logger.error "[#{Time.now.to_s(:db)}] ERROR #{error.message}"
      end
    end

    def self.stats(config_file = "#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
      config = YAML.load_file(config_file)
      return config['starling']['queue'], STARLING.sizeof(config['starling']['queue'])
    end

    def self.feedback(message)
      puts "== [SIMPLIFIED STARLING] ====================================="
      puts "=> #{message}"
    end

    def self.setup

      starling_folder = Dir.getwd + "/config/starling"
      starling_plugin_folder = Dir.getwd + "/vendor/plugins/simplified_starling"

      FileUtils.mkdir starling_folder unless File.exist?(starling_folder)

      %w( development test production ).each do |env|
        starling_config = Dir.getwd + "/config/starling/#{env}.yml"
        unless File.exist?(starling_config)
          FileUtils.cp starling_plugin_folder + "/files/config.yml.tpl", starling_config 
          puts "=> Copied configuration file to #{env}"
        end
      end

      starling_initializer = Dir.getwd + "/config/initializers/starling.rb"

      unless File.exist?(starling_initializer)
        FileUtils.cp starling_plugin_folder + "/files/initializer.rb", starling_initializer
        puts "=> Copied starling initializer"
      end

    end

  end

end