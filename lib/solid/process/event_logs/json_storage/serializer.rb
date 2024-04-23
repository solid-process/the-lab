# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module Serializer
    extend self

    def serialize(value)
      case value
      when nil, true, false, Integer, Float then value
      when Hash then serialize_hash(value)
      when Array then value.map { |val| serialize(val) }
      when String then serialize_string(value)
      when Solid::Model then S11n::SolidModel.serialize(value)
      when GlobalID::Identification then S11n::GlobalId.serialize(value)
      when ActiveSupport::HashWithIndifferentAccess then serialize_indifferent_hash(value)
      else
        if value.respond_to?(:permitted?) && value.respond_to?(:to_h)
          serialize_indifferent_hash(value.to_h)
        else
          S11n::ActiveJob.serialize!(value)
        end
      end
    rescue
      "S11N:ERR"
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
      symbol_keys = value.each_key.grep(Symbol).map!(&:to_s)

      serialize_hash!(value, S11n::HashObject::SYMBOL_KEYS_KEY => symbol_keys)
    end

    def serialize_indifferent_hash(value)
      result = serialize_hash!(value)
      result[S11n::HashObject::WITH_INDIFFERENT_ACCESS_KEY] = serialize(true)
      result
    end

    def serialize_hash!(hash, memo = {})
      hash.each_with_object(memo) do |(key, value), memo_hash|
        memo_hash[S11n::HashObject.key(key)] = serialize(value)
      end
    end

    # rubocop:disable Style/ClassEqualityComparison
    def serialize_string(value)
      return value if value.class == ::String

      S11n::ActiveJob.serialize(value)
    end
    # rubocop:enable Style/ClassEqualityComparison

    def deserialize_hash(value)
      return S11n::GlobalId.deserialize(value) if S11n::GlobalId.serialized?(value)
      return S11n::ActiveJob.deserialize(value) if S11n::ActiveJob.serialized?(value)
      return S11n::SolidModel.deserialize(value) if S11n::SolidModel.serialized?(value)

      hash = value.transform_values { deserialize(_1) }

      S11n::HashObject.deserialize(hash)
    end
  end
end
