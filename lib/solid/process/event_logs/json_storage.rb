# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  class SerializationError < ArgumentError; end

  class DeserializationError < StandardError
    def initialize # :nodoc:
      super("Error while trying to deserialize arguments: #{$!.message}")
      set_backtrace $!.backtrace
    end
  end

  require_relative "json_storage/s11n"
  require_relative "json_storage/records"
end
