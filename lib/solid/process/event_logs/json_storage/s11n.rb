# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module S11n # S11n = Serialization
    require_relative "s11n/active_job"
    require_relative "s11n/global_id"
    require_relative "s11n/solid_model"
    require_relative "s11n/hash_object"
  end
end