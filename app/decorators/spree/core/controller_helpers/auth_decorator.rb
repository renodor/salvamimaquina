# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module AuthDecorator
        def set_guest_token
          return if cookies.signed[:guest_token].present?

          # We need to add same_site and secure to guest_token cookie so that it is passed along when performing 3d Secure
          # Otherwise the cookie is lost and the order as well...
          cookies.permanent.signed[:guest_token] = Spree::Config[:guest_token_cookie_options].merge(
            value: SecureRandom.urlsafe_base64(nil, false),
            httponly: true,
            same_site: 'None',
            secure: true
          )
        end

        Spree::Core::ControllerHelpers::Auth.prepend self
      end
    end
  end
end
