# frozen_string_literal: true

module Solid::Process::EventLogs::Serialization
  class Model
    attr_reader :version, :root_name, :trace_id, :duration, :ids

    def self.serialize(event_logs)
      new(event_logs, action: :serialize)
    end

    def self.deserialize(arg)
      event_logs = arg.is_a?(::Hash) ? arg : ::JSON.parse(arg)

      new(event_logs.symbolize_keys, action: :deserialize)
    end

    EMPTY_HASH = {}.freeze

    def initialize(hash, action:)
      metadata = hash[:metadata] || EMPTY_HASH

      @ids = metadata[:ids] || hash[:ids]
      @trace_id = metadata[:trace_id] || hash[:trace_id]
      @duration = metadata[:duration] || hash[:duration]

      @version = hash.fetch(:version)

      @records = Records.items(hash.fetch(:records), action: action)

      @root_name = @records.dig(0, :root, :name) || "UNKNOWN"
    end

    def attributes(main_records_only: false)
      records = records(main_only: main_records_only)

      category = records[-1].dig(:result, :kind)

      {
        version: version,
        root_name: root_name,
        trace_id: trace_id,
        duration: duration,
        ids: ids,
        records: records,
        category: category
      }
    end

    alias_method :to_h, :attributes

    def records(main_only: false)
      main_only ? Records.filter_main(@records) : @records
    end
  end
end
