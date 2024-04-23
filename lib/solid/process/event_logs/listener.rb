# frozen_string_literal: true

class Solid::Process::EventLogsRecord
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
          records: Records.serialize(records)
        )
      end
    rescue => e
      err = "#{e.message} (#{e.class}); Backtrace: #{e.backtrace.join(", ")}"

      ::Rails.logger.warn "Error on #{self.class}#on_finish: #{err}"
    end
  end
end