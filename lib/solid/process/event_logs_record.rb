# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class Solid::Process::EventLogsRecord < ActiveRecord::Base
  self.table_name = "solid_process_event_logs"

  class Listener
    include ::Solid::Result::EventLogs::Listener

    def on_finish(event_logs:)
      ::Thread.new do
        ::ActiveRecord::Base.connection_pool.with_connection do
          create_event_logs(event_logs)
        end
      end
    end

    private

    def create_event_logs(event_logs)
      root_name = event_logs.dig(:records, 0, :root, :name) || "Unknown"
      metadata = event_logs[:metadata]
      records = event_logs[:records].map do |record|
        record.deep_transform_values { _1.is_a?(::Solid::Process) ? _1.class.name : _1 }
      end

      ::Solid::Process::EventLogsRecord.create!(
        version: event_logs[:version],
        root_name: root_name,
        trace_id: metadata[:trace_id],
        duration: metadata[:duration],
        ids: metadata[:ids],
        records: records
      )

    rescue => e
      err = "#{e.message} (#{e.class}); Backtrace: #{e.backtrace.join(", ")}"

      ::Kernel.warn "Error on Solid::Process::EventLogsRecord::Listener#on_finish: #{err}"
    end
  end
end
# rubocop:enable Rails/ApplicationRecord
