# frozen_string_literal:true

module Spree
  module UsersControllerDecorator
    def self.prepended(base)
      base.before_action :send_mapbox_api_to_frontend, only: %i[show edit]
    end

    def show
      super

      @address = @user.ship_address
    end

    def update_user_address
      current_spree_user.ship_address = Spree::Address.create(user_address_params)
      redirect_to account_path, notice: I18n.t('spree.account_updated')
    end

    def user_address_params
      params.require(:address).permit(:name, :phone, :address1, :address2, :district_id, :state_id, :country_id, :city, :latitude, :longitude)
    end

    private

    def send_mapbox_api_to_frontend
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    Spree::UsersController.prepend self
  end
end
