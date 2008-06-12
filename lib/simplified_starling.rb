module Simplified

  class Starling

    def self.prepare(queue)
      if STARLING.available_queues.include?(queue)
        start_processing(queue)
      else
        puts "== STARLING ERROR: Queue not available ==================="
      end
    end

    def self.start_processing(queue)
      daemonize()
      loop do
        job = STARLING.get(queue)
        begin
          job[:type].capitalize.constantize.find(job[:id]).send(job[:task])
        rescue Exception => error
          puts error
        end
      end
    end

    def self.feedback(message)
      puts "== [SIMPLIFIED STARLING] ====================================="
      puts "=> #{message}"
    end

  end

end