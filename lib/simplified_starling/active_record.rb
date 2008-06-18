module SimplifiedStarling

  class ActiveRecord::Base

    ##
    # Push record task into the queue
    #
    def push(task, queue = self.class.name.tableize)
      job = { :type => self.class.to_s, :id => self.id, :task => task }
      STARLING.set(queue, job)
    end

  end

end

class Class

  ##
  # Push a class method task into the queue
  #
  def push(task, queue = self.name.tableize)
    job = { :type => self.to_s, :task => task }
    STARLING.set(queue, job)
  end

end

ActiveRecord::Base.send(:include, SimplifiedStarling)