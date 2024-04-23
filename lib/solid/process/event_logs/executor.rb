# frozen_string_literal: true

class Solid::Process::EventLogsRecord
  module Executor
    concurrency = Rails.application.config.active_record.global_executor_concurrency || 4

    @thread_pool ||= Concurrent::ThreadPoolExecutor.new(
      min_threads: 0,
      max_threads: concurrency,
      max_queue: concurrency * 4,
      fallback_policy: :caller_runs
    )

    def self.post(&)
      @thread_pool.post { Rails.application.executor.wrap(&) }
    end
  end
end
