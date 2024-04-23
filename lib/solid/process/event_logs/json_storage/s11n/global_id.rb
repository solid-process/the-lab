# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module S11n::GlobalId
    extend self

    KEY = "sp_globalid"

    def serialized?(value)
      value.size == 1 && value.key?(KEY)
    end

    def deserialize(value)
      ::GlobalID::Locator.locate(value[KEY])
    end

    def serialize(value)
      {KEY => value.to_global_id.to_s}
    rescue ::URI::GID::MissingModelIdError
      raise SerializationError, "Unable to serialize #{value.class} " \
        "without an id. (Maybe you forgot to call save?)"
    end
  end
end
