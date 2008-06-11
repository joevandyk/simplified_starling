module Simplified

  class Starling

    def self.prepare(queue)
      if STARLING.available_queues.include?(queue)
        start_processing(queue)
      else
        puts "== STARLING ERROR: Queue not available ==================="
      end
    rescue Exception => error
      puts "== STARLING ERROR: #{error} ==============="
    end

    def self.start_processing(queue)
      pid = fork do
        Signal.trap('HUP', 'IGNORE')
        loop do
          job = STARLING.get(queue)
          begin
            job[:type].constantize.find(job[:id]).send(job[:task])
          rescue
            puts "Error on #{job}"
          end
        end
      end
      Process.detach(pid)
      ##
      # TODO: Store pid id in a file ...
      puts "== STARTING STARLING PROCESSOR == #{pid} ===================="
    end

  end

end