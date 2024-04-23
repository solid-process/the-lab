# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module Records
    extend self

    INTERMEDIATE_TYPES = %w[_continue_ _given_].freeze

    def filter_main(hash)
      hash.filter_map do |item|
        result = item["result"] || item[:result]
        type = result["type"] || result[:type]

        current = item["current"] || item[:current]
        current_id = current["id"] || current[:id]

        item if (type == "_given_" && current_id == 0) || !type.in?(INTERMEDIATE_TYPES)
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

    def serialize(value)
      case value
      when nil, true, false, Integer, Float then value
      when Hash then serialize_hash(value)
      when Array then value.map { |val| serialize(val) }
      when String then S11n::String.serialize(value)
      when GlobalID::Identification then S11n::GlobalId.serialize(value)
      else
        value
      end
    end

    private

    def serialize_hash(value)
      value.each_with_object({}) do |(key, value), hash|
        hash[S11n::Hash.key(key)] = serialize(value)
      end
    end

    def deserialize_hash(value)
      if S11n::GlobalId.serialized?(value)
        S11n::GlobalId.deserialize(value)
      else
        value
          .transform_values { |v| deserialize(v) }
          .symbolize_keys
      end
    end
  end
end
