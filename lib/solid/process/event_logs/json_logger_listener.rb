# frozen_string_literal: true

module Solid::Process::EventLogs
  class JsonLoggerListener
    include ActiveSupport::Configurable
    include Solid::Result::EventLogs::Listener

    config_accessor(:logger, :parameter_filter, :backtrace_cleaner)

    self.logger = Rails.logger
    self.parameter_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    self.backtrace_cleaner = Solid::Process::BacktraceCleaner.new

    def on_finish(event_logs:)
      logger.info(filter_and_serialize(event_logs).to_json)
    end

    def before_interruption(exception:, event_logs:)
      exception_data = {
        class: exception.class.name,
        message: exception.message,
        backtrace: backtrace_cleaner.clean(exception.backtrace).join("; ")
      }

      logger.error(filter_and_serialize(event_logs).merge(exception: exception_data).to_json)
    end

    private

    def filter_and_serialize(event_logs)
      records = event_logs[:records].map do
        result_value = parameter_filter.filter(_1[:result][:value].dup)

        _1.merge(result: _1[:result].merge(value: result_value))
      end

      filtered_event_logs = event_logs.merge(records: records)

      serialized_event_logs = Serialization::Model.serialize(filtered_event_logs).attributes(main_records_only: true)

      {event_logs: serialized_event_logs}
    end
  end
end
