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
        sleep(@sleep)
        def_task = CloudTm::DistributedExecutor.new
        landmarks_count = def_task.execute
        Rails.logger.debug "Will sleep for: #{@sleep}"

        Rails.logger.debug "Landmarks count: #{landmarks_count}"
      rescue Exception => ex
        Rails.logger.error "StatsService exception: #{ex} \n #{ex.backtrace.join('\\n')}"
      end
    
    end
    Rails.logger.warn "Stats service has quit!"

  end

	private

end