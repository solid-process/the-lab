# frozen_string_literal: true

module Solid::Process::EventLogs::JsonStorage
  module Records::Filter
    INTERMEDIATE_TYPES = %w[_continue_ _given_].freeze

    def self.only_main(hash)
      hash.filter_map do |item|
        current_id = (item["current"] || item[:current]).then { _1["id"] || _1[:id] }

        result_type = (item["result"] || item[:result]).then { _1["type"] || _1[:type] }

        item if (result_type == "_given_" && current_id == 0) || !result_type.in?(INTERMEDIATE_TYPES)
      end
    end
  end
end
