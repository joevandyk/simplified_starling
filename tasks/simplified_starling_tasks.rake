require 'starling'

namespace :simplified do

  namespace :starling do

    desc "Start Starling server"
    task :start do
      starling_binary = `which starling`.strip
      options = "--queue_path /tmp "
      options << "--pid /tmp/starling.pid"
      command = "#{starling_binary} #{options} -d"
      raise RuntimeError, "Cannot find starling." if starling_binary.blank?
      system command
      puts "== STARLING SUCCESSFULLY STARTED ======================"
    end

    desc "Stop Starling server"
    task :stop do
      system "kill -9 `cat /tmp/starling.pid`"
      puts "== STARLING SUCCESSFULLY STOPPED ======================"
    end

    desc "Queue Status"
    task :queues do
      begin
        starling = Starling.new('127.0.0.1:22122')
        items = starling.sizeof(:all)
        if items.empty?
          puts "== STARLING QUEUE IS EMPTY ============================"
        else
          puts "== STARLING QUEUES ===================================="
          items.each do |key, value|
            puts "=> #{key} has #{value} items."
          end
          puts "======================================================="
        end
      rescue Exception => error
        puts "== STARLING ERROR: #{error} ============"
      end
    end

    desc "Processor ..."
    task :processor do
      puts "=> Starts a processor that manages the queue."
    end

    task :push do
      starling = Starling.new('127.0.0.1:22122')
      starling.set("newsletter", { :id => 1, :task => 'test' })
      starling.set("newsletter", { :id => 1, :task => 'deliver' })
      starling.set("comment", { :id => 1500, :task => 'check_if_spam' })
    end

    task :pop do
      starling = Starling.new('127.0.0.1:22122')
      starling.get("newsletter")
      starling.get("comment")
    end

  end

end