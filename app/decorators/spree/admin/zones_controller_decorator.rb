# frozen_string_literal: true

module Spree
  module Admin
    module ZonesControllerDecorator
      private

      def load_data
        @countries = Spree::Country.order(:name)
        @states = Spree::State.includes(:country).order(:name)
        @districts = Spree::District.order(:name)
        @zones = Spree::Zone.order(:name)
      end

      Spree::Admin::ZonesController.prepend self
    end
  end
end
