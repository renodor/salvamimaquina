# frozen_string_literal: true

module Spree
  module OrdersControllerDecorator
    def self.prepended(base)
      base.before_action :send_mapbox_api_key_to_frontend, only: :show
    end

    def edit
      super

      gon.order_info = {
        number: @order.number,
        guest_token: @order.guest_token
      }
    end

    private

    def send_mapbox_api_key_to_frontend
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    Spree::OrdersController.prepend self
  end
end
