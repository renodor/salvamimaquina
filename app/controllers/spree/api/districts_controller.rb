# frozen_string_literal: true

module Spree
  module Api
    class DistrictsController < Spree::Api::BaseController
      skip_before_action :authenticate_user

      def index
        if params[:state_id]
          state = Spree::State.find(params[:state_id])
          @districts = state.districts
        else
          @districts = Spree::District.all
        end
      end
    end
  end
end
