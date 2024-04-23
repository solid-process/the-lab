# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module S11n::SolidModel
    KEY = "sp_solid_model"

    def self.serialized?(value)
      value.size == 1 && value.key?(KEY)
    end

    def self.serialize(value)
      {KEY => {"class_name" => value.class.name, "attributes" => value.attributes}}
    end

    def self.deserialize(value)
      class_name, attributes = value[KEY].fetch_values("class_name", "attributes")

      class_name.constantize.new(attributes)
    end
  end
end
