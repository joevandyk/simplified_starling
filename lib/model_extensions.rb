module ModelExtensions

  ##
  # Push item into the queue
  #
  def push(task, queue = self.class.name.tableize)
    job = { :type => self.class.to_s, :id => self.id, :task => task}
    STARLING.set(queue, job)
  end

end