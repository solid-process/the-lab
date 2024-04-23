# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class Solid::Process::EventLogsRecord < ActiveRecord::Base
  self.table_name = "solid_process_event_logs"

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

  class Listener
    include ::Solid::Result::EventLogs::Listener

    def on_finish(event_logs:)
      Executor.post { create_event_logs_record(event_logs) }
    end

    private

    def create_event_logs_record(event_logs)
      root_name = event_logs.dig(:records, 0, :root, :name) || "Unknown"
      metadata = event_logs[:metadata]
      records = event_logs[:records].map do |record|
        record.deep_transform_values { _1.is_a?(::Solid::Process) ? _1.class.name : _1 }
      end

      Rails.error.record do
        Solid::Process::EventLogsRecord.create!(
          version: event_logs[:version],
          root_name: root_name,
          trace_id: metadata[:trace_id],
          duration: metadata[:duration],
          ids: metadata[:ids],
          records: records
        )
      end
    rescue => e
      err = "#{e.message} (#{e.class}); Backtrace: #{e.backtrace.join(", ")}"

      ::Rails.logger.warn "Error on #{self.class}#on_finish: #{err}"
    end
  end
end
# rubocop:enable Rails/ApplicationRecord
