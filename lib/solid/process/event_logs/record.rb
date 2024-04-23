# frozen_string_literal: true

module Solid::Process::EventLogs
  require_relative "json_storage"

  # rubocop:disable Rails/ApplicationRecord
  class Record < ActiveRecord::Base
    require_relative "record/executor"
    require_relative "record/listener"

    self.table_name = "solid_process_event_logs"

    def raw_records
      self[:records]
    end

    def raw_main_records
      JsonStorage::Records.filter_main(raw_records)
    end

    def records
      JsonStorage::Records.deserialize(raw_records)
    end

    def main_records
      JsonStorage::Records.deserialize(raw_main_records)
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
