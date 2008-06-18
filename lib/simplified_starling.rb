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
          if job[:id]
            job[:type].constantize.find(job[:id]).send(job[:task])
          else
            job[:type].constantize.send(job[:task])
          end
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