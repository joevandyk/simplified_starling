module SimplifiedStarling

  ##
  # Push record task into the queue
  #
  def push(task)

    ActiveRecord::Base.verify_active_connections! if defined? (ActiveRecord)

    job = {}
    job[:type] = (self.kind_of? Class) ? self.to_s : self.class.to_s
    job[:id] = (self.kind_of? Class) ? nil : self.id
    job[:task] = task

    STARLING.set(STARLING_CONFIG['starling']['queue'], job)

    logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_starling.log")
    logger.info "[Pushed job @ #{Time.now.to_s(:db)}] #{job[:task].titleize.capitalize} #{job[:type].downcase} #{job[:id]}"

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