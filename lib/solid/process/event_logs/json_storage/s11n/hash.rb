# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module S11n::Hash
    extend self

    RESERVED_KEYS = Set[
      S11n::GlobalId::KEY, S11n::GlobalId::KEY.to_sym,
      S11n::SolidModel::KEY, S11n::SolidModel::KEY.to_sym
    ].freeze

    def key(arg)
      raise reserved_key_error(arg) if RESERVED_KEYS.include?(arg)

      case arg
      when ::String, ::Symbol then arg.to_s
      else raise invalid_key_error(arg)
      end
    end

    private

    def reserved_key_error(arg)
      SerializationError.new("Can't serialize a Hash with reserved key #{arg.inspect}")
    end

    def invalid_key_error(arg)
      message = "Only string and symbol hash keys may be serialized, but #{arg.inspect} is a #{arg.class}"

      SerializationError.new(message)
    end
  end
end
