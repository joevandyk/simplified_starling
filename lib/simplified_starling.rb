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
            job[:type].capitalize.constantize.find(job[:id]).send(job[:task])
          rescue Exception => error
            puts error
          end
        end
      end
      Process.detach(pid)

      pid_file = "log/starling_#{queue}_#{RAILS_ENV}.pid"
      File.open(pid_file, "w") { |f| f.write(pid) }
      File.chmod(0644, pid_file)

      # puts "== STARTING STARLING PROCESSOR =============================="

    end

    def self.feedback(message)
      puts "== [SIMPLFIED STARLING] ====================================="
      puts "=> #{message}"
    end

  end

end