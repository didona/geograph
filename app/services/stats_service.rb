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
        Rails.logger.warn "Will sleep for: #{@sleep}"

        Rails.logger.warn "Landmarks count: #{landmarks_count}"
      rescue Exception => ex
        Rails.logger.error "StatsService exception: #{ex} \n #{ex.backtrace.join('\\n')}"
      end
    
    end
    Rails.logger.error "Benchmark service quitting"

  end

	private

end