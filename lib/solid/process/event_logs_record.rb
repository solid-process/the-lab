# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class Solid::Process::EventLogsRecord < ActiveRecord::Base
  require_relative "event_logs/executor"
  require_relative "event_logs/listener"

  self.table_name = "solid_process_event_logs"
end
# rubocop:enable Rails/ApplicationRecord
