# frozen_string_literal: true

module Solid::Process::EventLogs
  class JsonLoggerListener
    include ActiveSupport::Configurable
    include Solid::Result::EventLogs::Listener

    config_accessor(:logger, :parameter_filter, :backtrace_cleaner)

    rails_root = Rails.root.to_s
    backtrace__cleaner = Solid::Process::BacktraceCleaner.new
    backtrace__cleaner.add_filter { |line| line.sub("#{rails_root}/", "") }

    self.logger = Rails.logger
    self.parameter_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    self.backtrace_cleaner = backtrace__cleaner

    def on_finish(event_logs:)
      serialized_attributes = filter_and_serialize_attributes(event_logs)

      json_data = {event_logs: serialized_attributes}

      logger.info(json_data.to_json)
    end

    def before_interruption(exception:, event_logs:)
      exception_data = {
        class: exception.class.name,
        message: exception.message,
        backtrace: backtrace_cleaner.clean(exception.backtrace).join("; ")
      }

      serialized_attributes = filter_and_serialize_attributes(event_logs)

      json_data = {event_logs: serialized_attributes, exception: exception_data}

      logger.error(json_data.to_json)
    end

    private

    def filter_and_serialize_attributes(event_logs)
      filter_and_serialize(event_logs).attributes(main_records_only: true)
    end

    def filter_and_serialize(event_logs)
      records = event_logs[:records].map do
        result = _1[:result]
        result_value = parameter_filter.filter(result[:value].dup)
        result_filtered = result.merge(value: result_value)

        and_then = _1[:and_then]
        and_then_arg = parameter_filter.filter(and_then[:arg].dup) if and_then[:arg]
        and_then_filtered = and_then.merge(arg: and_then_arg) if and_then[:arg]

        _1.merge(result: result_filtered, and_then: and_then_filtered || and_then)
      end

      filtered_event_logs = event_logs.merge(records: records)

      Serialization::Model.serialize(filtered_event_logs)
    end
  end
end
