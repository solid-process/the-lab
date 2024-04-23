# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class Solid::Process::EventLogsRecord < ActiveRecord::Base
  require_relative "event_logs/records"
  require_relative "event_logs/executor"
  require_relative "event_logs/listener"

  self.table_name = "solid_process_event_logs"

  def raw_records
    self[:records]
  end

  INTERMEDIATE_TYPES = %w[_continue_ _given_].freeze

  def raw_main_records
    raw_records.filter_map do
      type = _1.dig("result", "type")

      _1 if (type == "_given_" && _1.dig("current", "id") == 0) || !type.in?(INTERMEDIATE_TYPES)
    end
  end

  def records
    Records.deserialize(raw_records)
  end

  def main_records
    Records.deserialize(raw_main_records)
  end
end
# rubocop:enable Rails/ApplicationRecord
