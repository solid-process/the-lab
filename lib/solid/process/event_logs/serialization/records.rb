# frozen_string_literal: true

module Solid::Process::EventLogs::Serialization
  module Records
    require_relative "records/serialize"
    require_relative "records/deserialize"

    GIVEN_TYPE = ["_given_", :_given_].freeze
    GIVEN_OR_CONTINUE_TYPE = Set["_continue_", :_continue_, *GIVEN_TYPE].freeze

    def self.filter_main(items)
      items.filter_map do |item|
        current_id = (item["current"] || item[:current]).then { _1["id"] || _1[:id] }

        result_type = (item["result"] || item[:result]).then { _1["type"] || _1[:type] }

        item if (result_type.in?(GIVEN_TYPE) && current_id == 0) || !result_type.in?(GIVEN_OR_CONTINUE_TYPE)
      end
    end

    def self.serialize(array)
      Records::Serialize.list(array)
    end

    def self.deserialize(array)
      Records::Deserialize.list(array)
    end

    def self.items(array, action: :none)
      case action
      when :serialize then serialize(array)
      when :deserialize then deserialize(array)
      else array
      end
    end
  end
end
