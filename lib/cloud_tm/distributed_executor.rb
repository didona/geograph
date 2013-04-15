module CloudTm
	class DistributedExecutor
		def initialize
			cache = FenixFramework.getConfig.getBackEnd.getInfinispanCache
			@executor = CloudTm::DefaultExecutorService.new(cache)
		end

		def execute
			task = CloudTm::DistributedTask.new("")
			@executor.submitEverywhere(task)#.get
		end

	end
end