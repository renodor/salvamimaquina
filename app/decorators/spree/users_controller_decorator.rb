# frozen_string_literal:true

module Spree
  module UsersControllerDecorator
    def edit
      load_object
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    def show
      super

      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
      @address = @user.ship_address
    end

    def new_user_address
      load_object
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    def edit_user_address
      load_object
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    def update_user_address
      load_object
      current_spree_user.ship_address = Spree::Address.create(user_address_params)
      redirect_to account_path, notice: I18n.t('spree.account_updated')
    end

    def user_address_params
      params.require(:address).permit(:name, :phone, :address1, :address2, :district_id, :state_id, :country_id, :city, :latitude, :longitude)
    end

    private

    def load_object
      unless spree_current_user
        session['spree_user_return_to'] = '/account'
        redirect_to login_path and return
      end

      @user ||= Spree::User.find_by(id: spree_current_user.id)
      authorize! params[:action].to_sym, @user
    end

    Spree::UsersController.prepend self
  end
end
