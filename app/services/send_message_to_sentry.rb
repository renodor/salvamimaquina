# frozen_string_literal: true

class SendMessageToSentry
  def self.send(message, extra_data = {})
    Sentry.configure_scope do |scope|
      scope.set_context(
        'Extra data',
        extra_data.is_a?(Hash) ? extra_data : {}
      )
    end

    Sentry.capture_message(message)
  end
end
