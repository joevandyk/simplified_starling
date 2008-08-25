module SimplifiedStarling

  ##
  # Push record task into the queue
  #
  def push(task, *args)

    ActiveRecord::Base.verify_active_connections! if defined?(ActiveRecord)

    job = {}
    job[:type] = (self.kind_of? Class) ? self.to_s : self.class.to_s
    job[:id] = (self.kind_of? Class) ? nil : self.id
    job[:task] = task
    job[:options] = args 
    STARLING.set(STARLING_CONFIG['queue'], job)

    STARLING_LOG.info "[#{Time.now.to_s(:db)}] Pushed #{job[:task]} on #{job[:type]} #{job[:id]}"

  rescue Exception => error
    STARLING_LOG.error "[#{Time.now.to_s(:db)}] ERROR #{error.message}"
    raise MemCache::MemCacheError, error.message
  end

end

module SimplifiedStarling

  class ActiveRecord::Base
    include SimplifiedStarling
  end

end

class Class
  include SimplifiedStarling
end

ActiveRecord::Base.send(:include, SimplifiedStarling)
