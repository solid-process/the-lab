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

  def records
    Records.deserialize(raw_records)
  end
end
# rubocop:enable Rails/ApplicationRecord
