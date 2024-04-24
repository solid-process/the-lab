# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module S11n::GlobalId
    KEY = "sp_globalid"

    def self.serialized?(value)
      value.size == 1 && value.key?(KEY)
    end

    def self.serialize(value)
      {KEY => value.to_global_id.to_s}
    rescue ::URI::GID::MissingModelIdError
      raise SerializationError, "Unable to serialize #{value.class} " \
        "without an id. (Maybe you forgot to call save?)"
    end

    def self.deserialize(value)
      ::GlobalID::Locator.locate(value[KEY])
    end
  end
end
