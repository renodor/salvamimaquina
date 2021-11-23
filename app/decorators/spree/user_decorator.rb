# frozen_string_literal:true

module Spree
  module UserDecorator
    private

    def prepare_user_address(new_address)
      # add .includes(:address) to prevent N+1
      user_address = user_addresses.includes(:address).all_historical.find_first_by_address_values(new_address.attributes)
      user_address ||= user_addresses.build
      user_address.address = new_address
      user_address.archived = false
      user_address
    end

    Spree::User.prepend self
  end
end
