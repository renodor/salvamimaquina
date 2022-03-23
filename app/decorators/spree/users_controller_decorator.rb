# frozen_string_literal:true

module Spree
  module UsersControllerDecorator
    def edit
      load_object
    end

    def show
      # Something is wrong with solidus redirect on CanCan authorization failure,
      # if we don't add this guard condition, going from / to /mi_cuenta will redirect to / if user is not logged in...
      # (thus preventing user to login to avoid this redirect_back...)
      unless spree_current_user
        session['spree_user_return_to'] = '/mi_cuenta'
        redirect_to login_path and return
      end
      load_object

      @orders = @user.orders.complete.order('completed_at desc').includes(line_items: [variant: [images: [attachment_attachment: :blob]]])
      @address = @user.ship_address

      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    def new_user_address
      load_object
      @address = Spree::Address.build_default
      @address.state = Spree::State.find_by(name: 'Panamá')
      @address.city = 'Panamá'
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    def edit_user_address
      load_object
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    def update_user_address
      load_object
      current_spree_user.ship_address = Spree::Address.create(user_address_params)
      redirect_to account_es_mx_path, notice: I18n.t('spree.account_updated')
    end

    def user_address_params
      params.require(:address).permit(:name, :phone, :address1, :address2, :district_id, :state_id, :country_id, :city, :latitude, :longitude)
    end

    Spree::UsersController.prepend self
  end
end
