# frozen_string_literal: true

module Solid::Process::EventLogs
  class Record::Listener
    include ::Solid::Result::EventLogs::Listener

    def on_finish(event_logs:)
      Record::Executor.post { create_record(event_logs) }
    end

    private

    def create_record(event_logs)
      create_record!(event_logs)
    rescue => e
      err = "#{e.message} (#{e.class}); Backtrace: #{e.backtrace.join(", ")}"

      ::Rails.logger.warn "Error on #{self.class}#on_finish: #{err}"

      nil
    end

    def create_record!(event_logs)
      root_name = event_logs.dig(:records, 0, :root, :name) || "Unknown"
      metadata = event_logs[:metadata]
      records = JsonStorage::Records.serialize(event_logs[:records])

      ::Rails.error.record do
        Record.create!(
          version: event_logs[:version],
          root_name: root_name,
          trace_id: metadata[:trace_id],
          duration: metadata[:duration],
          ids: metadata[:ids],
          records: records
        )
      end
    end
  end
end
