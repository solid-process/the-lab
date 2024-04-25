# frozen_string_literal: true

require "active_job/arguments"
require "active_job/serializers"

module Solid::Process::EventLogs::Serialization
  module Value::ActiveJob
    KEY = "_aj_serialized"

    def self.serialized?(value)
      value.key?(KEY)
    end

    def self.serialize(value)
      serialize!(value)
    rescue ::ActiveJob::SerializationError
      value
    end

    def self.serialize!(value)
      ::ActiveJob::Serializers.serialize(value)
    end

    def self.deserialize(value)
      ::ActiveJob::Serializers.deserialize(value)
    end
  end
end
