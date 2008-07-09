module Simplified

  class Starling

    def self.prepare(queue)
      self.feedback("Queue processor started for `#{queue}`.")
      start_processing(queue)
    end

    def self.start_processing(queue, daemon = true)
      logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_starling.log")
      daemonize() if daemon
      loop do
        job = STARLING.get(queue)
        begin
          if job[:id]
            job[:type].constantize.find(job[:id]).send(job[:task])
          else
            job[:type].constantize.send(job[:task])
          end
          logger.info "[Popped job @ #{Time.now.to_s(:db)}] #{job[:task].titleize.capitalize} #{job[:type].downcase} #{job[:id]}"
        rescue ActiveRecord::RecordNotFound
          logger.warn "[WARNING] #{job[:type]}##{job[:id]} gone from database."
        rescue ActiveRecord::StatementInvalid
          logger.warn "[WARNING] Database connection gone, reconnecting & retrying."
          logger.info "          #{job.inspect}"
          STARLING.set(STARLING_CONFIG['starling']['queue'], job)
          logger.info "[Pushed job @ #{Time.now.to_s(:db)}] #{job[:task].titleize.capitalize} #{job[:type].downcase} #{job[:id]} (R)"
          ActiveRecord::Base.connection.reconnect! and retry
        rescue Exception => error
          logger.error error
        end
      end
    end

    def self.stats
      config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
      items = STARLING.sizeof(config['starling']['queue'])
      self.feedback("Queue `#{config['starling']['queue']}` has #{items} tasks.")
    rescue Exception => error
      self.feedback(error)
    end

    def self.feedback(message)
      puts "== [SIMPLIFIED STARLING] ====================================="
      puts "=> #{message}"
    end

  end

end