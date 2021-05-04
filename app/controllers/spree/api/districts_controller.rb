module Spree
  module Api
    class DistrictsController < Spree::Api::BaseController
      skip_before_action :authenticate_user

      def index
        # @districts = scope.ransack(params[:q]).result.
        #             includes(:country).order('name ASC')

        # if params[:page] || params[:per_page]
        #   @states = paginate(@states)
        # end

        # @state = Spree::State.find(params[:state_id])
        # @districts = @state.districts
        # District.all.to_json
        state = Spree::State.find(params[:state_id])
        @districts = state.districts
        @districts
        # respond_with(@districts)
      end

      private

      def scope
        if params[:state_id]
          @state = Spree::State.find(params[:state_id])
          @state.districts
        else
          Spree::State.accessible_by(current_ability)
        end
      end
    end
  end
end