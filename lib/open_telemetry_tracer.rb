module OpenTelemetryTracer
  SolidResultTracer = ::OpenTelemetry.tracer_provider.tracer("solid-result")

  module ProcessListener
    def self.start(name, _id, payload)
      scope = payload[:scope]

      span = SolidResultTracer.start_span("#{scope[:name]}#call", attributes: {
        "desc" => scope[:desc].inspect
      })

      token = OpenTelemetry::Context.attach(::OpenTelemetry::Trace.context_with_span(span))
      payload.merge!(__otel: {span:, token:})
    end

    def self.finish(_name, _id, payload)
      otel = payload.delete(:__otel)

      otel => { span:, token: }

      span.finish
      OpenTelemetry::Context.detach(token)
    end
  end

  module AndThenListener
    def self.start(name, _id, payload)
      payload => { scope:, and_then: }

      span = SolidResultTracer.start_span("#{scope[:name]}##{and_then[:method_name] || "block"}", attributes: {
        "type" => and_then[:type].to_s,
        "arg" => and_then[:arg].inspect
      })

      token = OpenTelemetry::Context.attach(::OpenTelemetry::Trace.context_with_span(span))
      payload.merge!(__otel: {span:, token:})
    end

    def self.finish(_name, _id, payload)
      otel = payload.delete(:__otel)

      otel => { span:, token: }

      span.finish
      OpenTelemetry::Context.detach(token)
    end
  end

  def self.subscribe
    ActiveSupport::Notifications.monotonic_subscribe("start_process.solid_process", ProcessListener)
    ActiveSupport::Notifications.monotonic_subscribe("and_then.solid_process", AndThenListener)
  end
end
