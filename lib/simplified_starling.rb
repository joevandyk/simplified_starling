module Simplified

  class Starling

    def self.prepare(queue)
      self.feedback("Queue processor started for `#{queue}`.")
      start_processing(queue)
    end

    def self.start_processing(queue, daemon = true)
      daemonize() if daemon
      loop do
        process(queue)
      end
    end

    def self.process(queue)
      logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_starling.log")
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
    rescue Exception => error
      self.feedback(error)
    end

    def self.feedback(message)
      puts "== [SIMPLIFIED STARLING] ====================================="
      puts "=> #{message}"
    end

  end

end