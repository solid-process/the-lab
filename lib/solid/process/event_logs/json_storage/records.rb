# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module Records
    extend self

    INTERMEDIATE_TYPES = %w[_continue_ _given_].freeze

    def filter_main(hash)
      hash.filter_map do |item|
        current_id = (item["current"] || item[:current]).then { _1["value"] || _1[:value] }

        result_type = (item["result"] || item[:result]).then { _1["type"] || _1[:type] }

        item if (result_type == "_given_" && current_id == 0) || !result_type.in?(INTERMEDIATE_TYPES)
      end
    end

    def serialize(value)
      case value
      when nil, true, false, Integer, Float then value
      when Hash then serialize_hash(value)
      when Array then value.map { |val| serialize(val) }
      when String then S11n::String.serialize(value)
      when Solid::Model then S11n::SolidModel.serialize(value)
      when GlobalID::Identification then S11n::GlobalId.serialize(value)
      else
        value
      end
    end

    def deserialize(value)
      case value
      when nil, true, false, String, Integer, Float then value
      when Hash then deserialize_hash(value)
      when Array then value.map { |val| deserialize(val) }
      else raise ArgumentError, "Can only deserialize primitive arguments: #{value.inspect}"
      end
    rescue
      raise DeserializationError
    end

    private

    def serialize_hash(value)
      value.each_with_object({}) do |(key, value), hash|
        hash[S11n::Hash.key(key)] = serialize(value)
      end
    end

    def deserialize_hash(value)
      return S11n::GlobalId.deserialize(value) if S11n::GlobalId.serialized?(value)
      return S11n::SolidModel.deserialize(value) if S11n::SolidModel.serialized?(value)

      value.transform_values { deserialize(_1) }.symbolize_keys
    end
  end
end
