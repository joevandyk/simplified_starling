##
# Load starling setting and connect application to starling.
#
begin
  STARLING_LOG = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_starling.log")
  STARLING_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/starling.yml")[RAILS_ENV]
  STARLING = Starling.new("#{STARLING_CONFIG['host']}:#{STARLING_CONFIG['port']}")
end
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

    def self.autoload_missing_constants
      yield
    rescue ArgumentError, MemCache::MemCacheError => error
      lazy_load ||= Hash.new { |hash, key| hash[key] = true; false }
      retry if error.to_s.include?('undefined class') && 
        !lazy_load[error.to_s.split.last.constantize]
      raise error
    end

    def self.pop(queue)
      begin

        job = autoload_missing_constants { STARLING.get(queue) }
        args = [job[:task]] + job[:options] # what to send to the object
        if job[:id]
          job[:type].constantize.find(job[:id]).send(*args)
        else
          job[:type].constantize.send(*args)
        end
        STARLING_LOG.info "[#{Time.now.to_s(:db)}] Popped #{job[:task]} on #{job[:type]} #{job[:id]}"
      rescue ActiveRecord::RecordNotFound
        STARLING_LOG.warn "[#{Time.now.to_s(:db)}] WARNING #{job[:type]}##{job[:id]} gone from database."
      rescue ActiveRecord::StatementInvalid
        STARLING_LOG.warn "[#{Time.now.to_s(:db)}] WARNING Database connection gone, reconnecting & retrying."
        ActiveRecord::Base.connection.reconnect! and retry
      rescue Exception => error
        STARLING_LOG.error "[#{Time.now.to_s(:db)}] ERROR #{error.message}"
      end
    end

    def self.stats
      config_file = Dir.getwd + "/config/starling.yml"
      config = YAML.load_file(config_file)[RAILS_ENV]
      return config['queue'], STARLING.sizeof(config['queue'])
    end

    def self.feedback(message)
      puts "=> [SIMPLIFIED STARLING] #{message}"
    end

    def self.setup
      starling_plugin_folder = Dir.getwd + "/vendor/plugins/simplified_starling"
      starling_config = Dir.getwd + "/config/starling.yml"
      unless File.exist?(starling_config)
        FileUtils.cp starling_plugin_folder + "/files/starling.yml.tpl", starling_config
        puts "=> Copied configuration file"
      end
    end

  end

end
