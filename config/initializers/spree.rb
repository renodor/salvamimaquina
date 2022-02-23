# frozen_string_literal:true

# Configure Solidus Preferences
# See http://docs.solidus.io/Spree/AppConfiguration.html for details

Spree.config do |config|
  # Core:

  # Default currency for new sites
  config.currency = 'USD'

  # from address for transactional emails
  config.mails_from = 'store@example.com'

  # set Panama has the default country
  config.default_country_iso = 'PA'

  # Use combined first and last name attribute in HTML views and API responses
  config.use_combined_first_and_last_name_in_address = true

  # Use legacy Spree::Order state machine
  config.use_legacy_order_state_machine = false

  # Customized order state machine to remove the confirm checkout step
  config.state_machines.order = '::StateMachines::Order'

  # Use the legacy address' state validation logic
  config.use_legacy_address_state_validator = false

  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  # When set, product caches are only invalidated when they fall below or rise
  # above the inventory_cache_threshold that is set. Default is to invalidate cache on
  # any inventory changes.
  # config.inventory_cache_threshold = 3

  # Enable Paperclip adapter for attachments on images and taxons
  config.image_attachment_module = 'Spree::Image::ActiveStorageAttachment'
  config.taxon_attachment_module = 'Spree::Taxon::ActiveStorageAttachment'

  # Disable legacy Solidus custom CanCanCan actions aliases
  config.use_custom_cancancan_actions = false

  # Defaults

  # Set this configuration to `true` to raise an exception when
  # an order is populated with a line item with a mismatching
  # currency. The `false` value will just add a validation error
  # and will be the only behavior accepted in future versions.
  # See https://github.com/solidusio/solidus/pull/3456 for more info.
  config.raise_with_invalid_currency = false

  # Set this configuration to false to always redirect the user to
  # /unauthorized when needed, without trying to redirect them to
  # their previous location first.
  config.redirect_back_on_unauthorized = true

  # Set this configuration to `true` to allow promotions
  # with no associated actions to be considered active for use by customers.
  # See https://github.com/solidusio/solidus/pull/3749 for more info.
  config.consider_actionless_promotion_active = false

  # Set this configuration to `false` to avoid running validations when
  # updating an order. Be careful since you can end up having inconsistent
  # data in your database turning it on.
  # See https://github.com/solidusio/solidus/pull/3645 for more info.
  config.run_order_validations_on_order_updater = true

  # Permission Sets:

  # Uncomment and customize the following line to add custom permission sets
  # to a custom users role:
  # config.roles.assign_permissions :role_name, ['Spree::PermissionSets::CustomPermissionSet']

  # Overwrite default user role to add UserAddressManagement permissions
  config.roles.assign_permissions :default, ['Spree::PermissionSets::DefaultCustomer', 'Spree::PermissionSets::UserAddressManagement']

  # Frontend:

  # Custom logo for the frontend
  config.logo = 'logo-smm.png'

  # Template to use when rendering layout
  # config.layout = "spree/layouts/spree_application"

  # Admin:

  # Custom logo for the admin
  config.admin_interface_logo = 'logo-smm.png'

  # Gateway credentials can be configured statically here and referenced from
  # the admin. They can also be fully configured from the admin.
  #
  # Please note that you need to use the solidus_stripe gem to have
  # Stripe working: https://github.com/solidusio-contrib/solidus_stripe
  #
  # config.static_model_preferences.add(
  #   Spree::PaymentMethod::StripeCreditCard,
  #   'stripe_env_credentials',
  #   secret_key: ENV['STRIPE_SECRET_KEY'],
  #   publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  #   server: Rails.env.production? ? 'production' : 'test',
  #   test_mode: !Rails.env.production?
  # )

  config.products_per_page = 1000
end

Spree::Frontend::Config.configure do |config|
  config.locale = 'es-MX'
end

# rubocop:disable Metrics/BlockLength
Spree::Backend::Config.configure do |config|
  config.locale = 'en'

  # Add new items to admin menu
  config.menu_items += [
    config.class::MenuItem.new(
      %i[trade_in_requests trade_in_models],
      'money',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      url: '/admin/trade_in_models',
      partial: 'spree/admin/shared/trade_in_sub_menu',
      label: :trade_in
    ),
    config.class::MenuItem.new(
      %i[reparation_categories reparation_requests],
      'laptop',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      url: '/admin/reparation_categories',
      partial: 'spree/admin/shared/reparations_sub_menu',
      label: :reparations
    ),
    config.class::MenuItem.new(
      [:sync_repair_shopr],
      'refresh',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      url: '/admin/sync_repair_shopr'
    ),
    config.class::MenuItem.new(
      [:banners],
      'picture-o',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      url: '/admin/banners'
    ),
    config.class::MenuItem.new(
      [:sliders],
      'forward',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      url: '/admin/sliders'
    )
  ]
end
# rubocop:enable Metrics/BlockLength

Spree::Api::Config.configure do |config|
  config.requires_authentication = true
end

# Prevent solidus auth to ask user to registrate before checkout
# Spree::Auth::Config[:registration_step] = false

Spree.user_class = 'Spree::LegacyUser'

# Add custom shipping calculator
Rails.application.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::CustomShippingCalculator

# Add custom payment method
Rails.application.config.spree.payment_methods << Spree::PaymentMethod::BacCreditCard

# Add custom promotion rule
Rails.application.config.spree.promotions.rules << Spree::Promotion::Rules::ShippingMethod

# Permit custom address attributes
Spree::PermittedAttributes.address_attributes.push(:district_id, :latitude, :longitude)

# Rules for avoiding to store the current path into session for redirects
# When at least one rule is matched, the request path will not be stored
# in session.
# You can add your custom rules by uncommenting this line and changing
# the class name:
#
# Spree::UserLastUrlStorer.rules << 'Spree::UserLastUrlStorer::Rules::AuthenticationRule'
