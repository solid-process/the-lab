# frozen_string_literal: true

module Solid::Process::EventLogs
  require_relative "serialization"

  # rubocop:disable Rails/ApplicationRecord
  class Record < ActiveRecord::Base
    require_relative "record/executor"
    require_relative "record/listener"

    self.table_name = "solid_process_event_logs"

    enum category: {success: "success", failure: "failure", error: "error"}

    def raw_records
      self[:records]
    end

    def raw_main_records
      Serialization::Records.filter_main(raw_records)
    end

    def records
      @records ||= Serialization::Records.deserialize(raw_records)
    end

    def main_records
      @main_records ||=
        if defined?(@records)
          Serialization::Records.filter_main(@records)
        else
          Serialization::Records.deserialize(raw_main_records)
        end
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[id root_name duration trace_id created_at]
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
