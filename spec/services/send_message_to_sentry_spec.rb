# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendMessageToSentry, type: :service do
  describe '.send' do
    let(:message) { 'Test message' }
    let(:extra_data) { { key: 'value' } }
    let(:scope_double) { double('Sentry::Scope', set_context: nil) }

    it 'captures the message with extra data context to Sentry' do
      allow(Sentry).to receive(:configure_scope).and_yield(scope_double)
      expect(scope_double).to receive(:set_context).with('Extra data', extra_data)
      expect(Sentry).to receive(:capture_message).with(message)

      SendMessageToSentry.send(message, extra_data)
    end

    it 'captures the message to Sentry without extra data if not provided' do
      allow(Sentry).to receive(:configure_scope).and_yield(scope_double)
      expect(scope_double).to receive(:set_context).with('Extra data', {})
      expect(Sentry).to receive(:capture_message).with(message)

      SendMessageToSentry.send(message)
    end

    it 'captures the message to Sentry with an empty hash as extra data if extra_data is not a hash' do
      invalid_extra_data = 'not_a_hash'
      allow(Sentry).to receive(:configure_scope).and_yield(scope_double)
      expect(scope_double).to receive(:set_context).with('Extra data', {})
      expect(Sentry).to receive(:capture_message).with(message)

      SendMessageToSentry.send(message, invalid_extra_data)
    end
  end
end
