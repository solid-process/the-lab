# frozen_string_literal: true

require "solid/validators/is_validator"
require "solid/validators/id_validator"
require "solid/validators/email_validator"
require "solid/validators/instance_of_validator"

require "solid/process/event_logs/record"
require "solid/process/event_logs/json_logger_listener"
# require "solid/process/event_logs/basic_logger_listener"

require "solid/process/active_support_publisher"

require "open_telemetry_tracer"
OpenTelemetryTracer.subscribe

# Solid::Process::EventLogs::BasicLoggerListener.logger = Rails.logger

Solid::Result.configuration do |config|
  config.event_logs.listener = Solid::Result::EventLogs::Listeners[
    Solid::Process::EventLogs::JsonLoggerListener,
    Solid::Process::EventLogs::Record::Listener,
    Solid::Process::ActiveSupportPublisher
  ]
end
