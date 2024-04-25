# frozen_string_literal: true

module Solid::Process::EventLogs::Serialization
  ERR_CODE = "S11N:ERR"

  require_relative "serialization/errors"
  require_relative "serialization/value"
  require_relative "serialization/records"
  require_relative "serialization/model"
end
