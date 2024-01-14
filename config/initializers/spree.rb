# Configure Solidus Preferences
# See http://docs.solidus.io/Spree/AppConfiguration.html for details

# Solidus version defaults for preferences that are not overridden
Spree.load_defaults '4.2.3'

Spree.config do |config|
  # Core:
  # Default currency for new sites
  config.currency = 'USD'

  config.default_country_iso = 'PA'

  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  # When set, product caches are only invalidated when they fall below or rise
  # above the inventory_cache_threshold that is set. Default is to invalidate cache on
  # any inventory changes.
  # config.inventory_cache_threshold = 3

  # Configure adapter for attachments on products and taxons (use ActiveStorageAttachment or PaperclipAttachment)
  config.image_attachment_module = 'Spree::Image::ActiveStorageAttachment'
  config.taxon_attachment_module = 'Spree::Taxon::ActiveStorageAttachment'

  # Defaults
  # Permission Sets:

  # Uncomment and customize the following line to add custom permission sets
  # to a custom users role:
  # config.roles.assign_permissions :role_name, ['Spree::PermissionSets::CustomPermissionSet']

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

  # Add custom shipping calculator
  config.environment.calculators.shipping_methods << 'Spree::Calculator::Shipping::CustomShippingCalculator'

  # Add custom payment method
  config.environment.payment_methods << 'Spree::PaymentMethod::BacCreditCard'

  # Add custom promotion rule
  config.environment.promotions.rules << 'Spree::Promotion::Rules::ShippingMethod'

  # Set our own custom Order mailer
  config.order_mailer_class = 'OrderCustomMailer'
end

Spree::Backend::Config.configure do |config|
  config.locale = 'en'

  # Uncomment and change the following configuration if you want to add
  # a new menu item:
  #
  config.menu_items += [
    config.class::MenuItem.new(
      label: :trade_in,
      icon: 'money', # see https://fontawesome.com/v4/icons/
      url: '/admin/trade_in_models',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      partial: 'spree/admin/shared/sub_menus/trade_in',
      children: [
        config.class::MenuItem.new(
          label: :trade_in_models,
          match_path: '/admin/trade_in_models'
        ),
        config.class::MenuItem.new(
          label: :trade_in_requests,
          match_path: '/admin/trade_in_requests'
        )
      ]
    ),
    config.class::MenuItem.new(
      label: :reparations,
      icon: 'laptop',
      url: '/admin/reparation_categories',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      partial: 'spree/admin/shared/sub_menus/reparations',
      children: [
        config.class::MenuItem.new(
          label: :reparation_categories,
          match_path: '/admin/reparation_categories'
        ),
        config.class::MenuItem.new(
          label: :reparation_requests,
          match_path: '/admin/reparation_requests'
        )
      ]
    ),
    config.class::MenuItem.new(
      label: :sync_repair_shopr,
      icon: 'refresh',
      url: '/admin/sync_repair_shopr',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
    ),
    config.class::MenuItem.new(
      label: :sliders_and_banners,
      icon: 'picture-o',
      url: '/admin/sliders',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
    ),
    config.class::MenuItem.new(
      label: :documentation,
      icon: 'book',
      url: '/admin/documentation',
      condition: -> { current_spree_user&.has_spree_role?(:admin) },
      partial: 'spree/admin/shared/sub_menus/documentation',
      children: [
        config.class::MenuItem.new(
          label: :doc_products,
          url: '/admin/documentation'
        ),
        config.class::MenuItem.new(
          label: :doc_promotions,
          url: '/admin/documentation#promotions'
        ),
        config.class::MenuItem.new(
          label: :doc_users,
          url: '/admin/documentation#users'
        ),
        config.class::MenuItem.new(
          label: :doc_settings,
          url: '/admin/documentation#settings'
        ),
        config.class::MenuItem.new(
          label: :doc_trade_in,
          url: '/admin/documentation#trade_in'
        ),
        config.class::MenuItem.new(
          label: :doc_reparations,
          url: '/admin/documentation#reparations'
        ),
        config.class::MenuItem.new(
          label: :doc_repair_shopr,
          url: '/admin/documentation#repair_shopr'
        ),
        config.class::MenuItem.new(
          label: :doc_sliders,
          url: '/admin/documentation#sliders'
        )
      ]
    )
  ]

  # Custom frontend product path
  #
  # config.frontend_product_path = ->(template_context, product) {
  #   template_context.spree.product_path(product)
  # }
end

Spree::Api::Config.configure do |config|
  config.requires_authentication = true
end

# Rules for avoiding to store the current path into session for redirects
# When at least one rule is matched, the request path will not be stored
# in session.
# You can add your custom rules by uncommenting this line and changing
# the class name:
#
# Spree::UserLastUrlStorer.rules << 'Spree::UserLastUrlStorer::Rules::AuthenticationRule'

# Permit custom address attributes
Spree::PermittedAttributes.address_attributes.push(:district_id, :latitude, :longitude)
