module SimplifiedStarling

  ##
  # Push record task into the queue
  #
  def push(task)
    job = { :type => self.class.to_s, :id => (self.kind_of? Class) ? nil : self.id, :task => task }
    STARLING.set(STARLING_CONFIG['starling']['queue'], job)
    logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_starling.log")
    model = job[:id] ? self.class : self.to_s
    logger.info "Job: #{task.titleize.capitalize} #{model.to_s.downcase} #{job[:id]}"
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