# frozen_string_literal: true

Rails.application.config.to_prepare do
  OrderSubscriber.new.subscribe_to(Spree::Bus)
end
