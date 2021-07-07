# frozen_string_literal: true

class CaptureMessageToSentry < ActiveJob::Base
  queue_as :default

  def perform(message, options = {})
    Sentry.capture_message(message, options)
  end
end
