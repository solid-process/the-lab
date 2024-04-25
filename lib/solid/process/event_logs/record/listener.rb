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
      ::Rails.error.record do
        serializad_event_logs = Serialization::Model.serialize(event_logs)

        Record.create!(serializad_event_logs.attributes)
      end
    end
  end
end
