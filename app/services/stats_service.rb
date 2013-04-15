class StatsService
	
	def initialize(opts={})
    @sleep = opts['sleep']
  end

  def start
    Thread.new { run }
  end

  def stop
    @done = true
  end

  def run
    until @done
    	
      begin
        def_task = CloudTm::DistributedExecutor.new
        landmarks_count = def_task.execute

        sleep(@sleep)

        Rails.logger.warn "Landmarks count: #{landmarks_count}"
      rescue Exception => ex
        Rails.logger.debug "StatsService exception: #{ex}"
      end
    
    end

  end

	private

end