# frozen_string_literal: true

# Following this guide recomendationns to add new permissions:
# https://guides.solidus.io/developers/customizations/customizing-permissions.html#customizing-permissions
module Spree
  module PermissionSets
    class UserAddressManagement < PermissionSets::Base
      def activate!
        can %i[new_user_address edit_user_address update_user_address], Spree.user_class, id: user.id
      end
    end
  end
end
