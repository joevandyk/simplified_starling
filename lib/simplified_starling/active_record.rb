module SimplifiedStarling

  class ActiveRecord::Base

    ##
    # Push record task into the queue
    #
    def push(task)
      job = { :type => self.class.to_s, :id => self.id, :task => task }
      STARLING.set(STARLING_CONFIG['starling']['queue'], job)
    end

  end

end

class Class

  ##
  # Push a class method task into the queue
  #
  def push(task)
    job = { :type => self.to_s, :task => task }
    STARLING.set(STARLING_CONFIG['starling']['queue'], job)
  end

end

ActiveRecord::Base.send(:include, SimplifiedStarling)