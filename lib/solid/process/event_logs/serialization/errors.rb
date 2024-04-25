# frozen_string_literal: true

module Solid::Process::EventLogs::Serialization
  class DumpError < ArgumentError; end

  class LoadError < StandardError
    def initialize # :nodoc:
      super("Error while trying to deserialize arguments: #{$!.message}")
      set_backtrace $!.backtrace
    end
  end
end
