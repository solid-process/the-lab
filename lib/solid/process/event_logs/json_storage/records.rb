# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module Records
    require_relative "records/filter"

    SerializeResultSource = lambda do |source|
      return unless source

      source.is_a?(Module) ? source.name : source.class.name
    end

    def self.serialize(array)
      array.map { serialize_one(_1) }
    end

    def self.serialize_one(hash)
      result = hash[:result].dup
      result[:value] = result[:value].transform_values { Serializer.serialize(_1) }
      result[:source] = SerializeResultSource.call(result[:source])

      and_then = hash[:and_then].dup
      and_then[:arg] = and_then[:arg].transform_values { Serializer.serialize(_1) } if and_then[:arg]

      {
        root: hash[:root],
        parent: hash[:parent],
        current: hash[:current],
        result: result,
        and_then: and_then,
        time: hash[:time].iso8601(5)
      }
    end

    def self.deserialize(array)
      array.map { deserialize_one(_1) }
    end

    def self.deserialize_one(hash)
      result = hash["result"].each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = (key == "value") ? val : val.to_sym
      end

      result[:value] = result[:value].each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = Serializer.deserialize(val)
      end

      and_then = hash["and_then"].each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = (key == "arg") ? val : val.to_sym
      end

      if and_then[:arg]
        and_then[:arg] = and_then[:arg].each_with_object({}) do |(key, val), memo|
          memo[key.to_sym] = Serializer.deserialize(val)
        end
      end

      {
        root: hash["root"].symbolize_keys!,
        parent: hash["parent"].symbolize_keys!,
        current: hash["current"].symbolize_keys!,
        result: result,
        and_then: and_then,
        time: Time.zone.parse(hash["time"])
      }
    end
  end
end
