# frozen_string_literal: true

class SendEventToSentryJob < ActiveJob::Base
  queue_as :default

  def perform(event, hint)
    Sentry.send_event(event, hint)
  end
end
