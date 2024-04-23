# frozen_string_literal: true

class Solid::Process::EventLogsRecord
  module Records
    extend self

    GLOBALID_KEY = "sp_globalid"

    RESERVED_KEYS = [GLOBALID_KEY, GLOBALID_KEY.to_sym].freeze

    class SerializationError < ArgumentError; end

    class DeserializationError < StandardError
      def initialize # :nodoc:
        super("Error while trying to deserialize arguments: #{$!.message}")
        set_backtrace $!.backtrace
      end
    end

    def deserialize(value)
      deserialize!(value)
    rescue
      raise DeserializationError
    end

    def deserialize!(value)
      case value
      when nil, true, false, String, Integer, Float
        value
      when Array
        value.map { |val| deserialize(val) }
      when Hash
        if serialized_global_id?(value)
          deserialize_global_id(value)
        else
          deserialize_hash(value).symbolize_keys
        end
      else
        raise ArgumentError, "Can only deserialize primitive arguments: #{value.inspect}"
      end
    end

    def serialize(value)
      case value
      when nil, true, false, Integer, Float # Types that can hardly be subclassed
        value
      when String
        if value.instance_of?(String)
          value
        else
          begin
            Serializers.serialize(value)
          rescue SerializationError
            value
          end
        end
      when Array
        value.map { |val| serialize(val) }
      when Hash
        serialize_hash(value)
      when GlobalID::Identification
        convert_to_global_id_hash(value)
      else
        value
      end
    end

    private

    def serialize_hash(argument)
      argument.each_with_object({}) do |(key, value), hash|
        hash[serialize_hash_key(key)] = serialize(value)
      end
    end

    def deserialize_hash(serialized_hash)
      serialized_hash.transform_values { |v| deserialize(v) }
    end

    def serialize_hash_key(key)
      raise SerializationError.new("Can't serialize a Hash with reserved key #{key.inspect}") if key.in?(RESERVED_KEYS)

      case key
      when String, Symbol
        key.to_s
      else
        raise SerializationError.new("Only string and symbol hash keys may be serialized as job arguments, but #{key.inspect} is a #{key.class}")
      end
    end

    def serialized_global_id?(hash)
      hash.size == 1 && hash.include?(GLOBALID_KEY)
    end

    def deserialize_global_id(hash)
      GlobalID::Locator.locate hash[GLOBALID_KEY]
    end

    def convert_to_global_id_hash(argument)
      {GLOBALID_KEY => argument.to_global_id.to_s}
    rescue URI::GID::MissingModelIdError
      raise SerializationError, "Unable to serialize #{argument.class} " \
        "without an id. (Maybe you forgot to call save?)"
    end
  end
end
