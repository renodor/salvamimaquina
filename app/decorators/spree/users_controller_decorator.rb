# frozen_string_literal:true

module Spree
  module UsersControllerDecorator
    def update_user_address
      address = Spree::Address.new(user_address_params)
      address.city = 'Panamá'
      address.state = Spree::State.find_by(name: 'Panamá')
      address.country = Spree::Country.find_by(name: 'Panama')
      address.save!

      current_spree_user.ship_address = address
      # current_spree_user.ship_address.update!()
      redirect_to account_path
    end

    def user_address_params
      params.require(:address).permit(:name, :phone, :address1, :address2, :district_id)
    end

    Spree::UsersController.prepend self
  end
end
