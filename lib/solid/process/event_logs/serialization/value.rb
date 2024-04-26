# frozen_string_literal: true

module Solid::Process::EventLogs::Serialization
  module Value
    require_relative "value/active_job"
    require_relative "value/global_id"
    require_relative "value/solid_model"
    require_relative "value/hash_object"

    ERROR = "[ERROR]"

    extend self

    def serialize(value)
      case value
      when nil, true, false, Integer, Float then value
      when Hash then serialize_hash(value)
      when Array then value.map { |val| serialize(val) }
      when String then serialize_string(value)
      when Solid::Model then Value::SolidModel.serialize(value)
      when GlobalID::Identification then Value::GlobalId.serialize(value)
      when ActiveSupport::HashWithIndifferentAccess then serialize_indifferent_hash(value)
      else
        if value.respond_to?(:permitted?) && value.respond_to?(:to_h)
          serialize_indifferent_hash(value.to_h)
        else
          Value::ActiveJob.serialize!(value)
        end
      end
    rescue
      ERROR
    end

    def deserialize(value)
      case value
      when nil, true, false, String, Integer, Float then value
      when Hash then deserialize_hash(value)
      when Array then value.map { |val| deserialize(val) }
      else raise ArgumentError, "Can only deserialize primitive arguments: #{value.inspect}"
      end
    rescue
      raise LoadError
    end

    private

    def serialize_hash(value)
      symbol_keys = value.each_key.grep(Symbol).map!(&:to_s)

      serialize_hash!(value, Value::HashObject::SYMBOL_KEYS_KEY => symbol_keys)
    end

    def serialize_indifferent_hash(value)
      result = serialize_hash!(value)
      result[Value::HashObject::WITH_INDIFFERENT_ACCESS_KEY] = serialize(true)
      result
    end

    def serialize_hash!(hash, memo = {})
      hash.each_with_object(memo) do |(key, value), memo_hash|
        memo_hash[Value::HashObject.key(key)] = serialize(value)
      end
    end

    # rubocop:disable Style/ClassEqualityComparison
    def serialize_string(value)
      return value if value.class == ::String

      Value::ActiveJob.serialize(value)
    end
    # rubocop:enable Style/ClassEqualityComparison

    def deserialize_hash(value)
      return Value::GlobalId.deserialize(value) if Value::GlobalId.serialized?(value)
      return Value::ActiveJob.deserialize(value) if Value::ActiveJob.serialized?(value)
      return Value::SolidModel.deserialize(value) if Value::SolidModel.serialized?(value)

      hash = value.transform_values { deserialize(_1) }

      Value::HashObject.deserialize(hash)
    end
  end
end
