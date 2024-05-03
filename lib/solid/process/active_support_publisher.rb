class Solid::Process::ActiveSupportPublisher
  include Solid::Result::EventLogs::Listener

  def self.around_event_logs?
    true
  end

  def self.around_and_then?
    true
  end

  def around_event_logs(scope:, &)
    ActiveSupport::Notifications.instrument("start_process.solid_process", scope:, &)
  end

  def around_and_then(scope:, and_then:, **, &)
    ActiveSupport::Notifications.instrument("and_then.solid_process", scope:, and_then:, &)
  end
end
