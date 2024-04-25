# frozen_string_literal: true

module Solid::Process::EventLogs::Serialization
  module Records::Serialize
    def self.list(array)
      array.map { item(_1) }
    end

    def self.item(hash)
      result = hash[:result].dup
      result[:value] = result[:value].transform_values { Value.serialize(_1) }
      result[:source] = result[:source].try { _1.is_a?(Module) ? _1.name : _1.class.name }

      and_then = hash[:and_then].dup
      and_then[:arg] = and_then[:arg].transform_values { Value.serialize(_1) } if and_then[:arg]

      {
        root: hash[:root],
        parent: hash[:parent],
        current: hash[:current],
        result: result,
        and_then: and_then,
        time: hash[:time].iso8601(5)
      }
    end
  end
end
