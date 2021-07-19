# frozen_string_literal: true

# TODO: rename to SendEventToSentryJob (everywhere...)
class SendEventToSentry < ActiveJob::Base
  queue_as :default

  def perform(event, hint)
    Sentry.send_event(event, hint)
  end
end
