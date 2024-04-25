# frozen_string_literal: true

module Solid::Process::EventLogs::Serialization
  module Records::Deserialize
    def self.list(array)
      array.map { item(_1) }
    end

    def self.item(hash)
      result = hash["result"].each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = (key == "value") ? val : val.to_sym
      end

      result[:value] = result[:value].each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = Value.deserialize(val)
      end

      and_then = hash["and_then"].each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = (key == "arg") ? val : val.to_sym
      end

      if and_then[:arg]
        and_then[:arg] = and_then[:arg].each_with_object({}) do |(key, val), memo|
          memo[key.to_sym] = Value.deserialize(val)
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
