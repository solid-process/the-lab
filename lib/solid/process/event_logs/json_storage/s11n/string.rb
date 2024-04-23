# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module S11n::String
    # rubocop:disable Style/ClassEqualityComparison
    def self.serialize(value)
      return value if value.class == ::String

      begin
        ::ActiveJob::Serializers.serialize(value)
      rescue ::ActiveJob::SerializationError
        value
      end
    end
    # rubocop:enable Style/ClassEqualityComparison
  end
end
