# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :setup_prod_db do
  task run: %i[
    environment
    create_store
    create_stock_locations
    create_taxonomies
    create_panama_country
    create_panama_city_corregimientos
    create_panama_zone
    create_panama_city_zones
    create_tax_category
    create_shipping_methods
    destroy_countries_and_states_out_of_panama
    create_payment_methods
    create_free_shipping_promotion
    create_cross_sells_relation_type
    create_admin_spree_role
  ]

  task :create_store do
    Rails.logger.info('Create Store')

    store = Spree::Store.first || Spree::Store.new

    store.update!(
      name: 'Salva Mi Máquina',
      url: 'www.salvamimaquina.com',
      mail_from_address: 'administracion@salvamimaquina.com',
      meta_description: 'Venta y servicio técnico de equipos Apple y Windows. Diagnostico rápido y precios accesibles',
      seo_title: 'Lideres en reparacion de equipos Apple',
      default_currency: 'USD',
      code: 'salvamimaquina',
      default: true,
      available_locales: ['es-MX'],
      cart_tax_country_iso: 'PA'
    )
  end

  task :create_stock_locations do
    Rails.logger.info('Create Bella Vista and San Francisco Stock Locations')

    Spree::StockLocation.find_or_initialize_by(repair_shopr_id: 1928).update!(
      name: 'Bella Vista',
      backorderable_default: false
    )

    Spree::StockLocation.find_or_initialize_by(repair_shopr_id: 1927).update!(
      name: 'San Francisco',
      backorderable_default: false
    )

    Spree::StockLocation.where.not(repair_shopr_id: [1928, 1927])
                        .or(Spree::StockLocation.where(repair_shopr_id: nil))
                        .destroy_all
  end

  task :create_taxonomies do
    Rails.logger.info('Create Categories Taxonomies')

    categories_taxonomy = Spree::Taxonomy.find_or_create_by!(name: 'Categories', position: 1)
    categories_taxon = categories_taxonomy.taxons.find_or_initialize_by(name: 'Todo', position: 1)
    categories_taxon.update!(permalink: 'todos_los_productos')

    Spree::Taxonomy.where.not(id: categories_taxonomy.id).destroy_all
  end

  task :create_panama_country do
    Rails.logger.info('Create Panama country')

    panama_country = Spree::Country.find_or_initialize_by(name: 'Panama')
    panama_country.update!(
      iso_name: 'PANAMA',
      iso: 'PA',
      iso3: 'PAN',
      numcode: 591,
      states_required: true
    )
  end

  task :create_panama_city_corregimientos do
    Rails.logger.info('Create Panama City corregimientos')

    panama_country = Spree::Country.find_by!(name: 'Panama')
    panama_state_id = Spree::State.find_or_create_by!(name: 'Panamá', country_id: panama_country.id).id
    corregimientos = [
      {
        name: '24 de Diciembre',
        longitude: -79.360813,
        latitude: 9.099316
      },
      {
        name: 'Ancón',
        longitude: -79.549556,
        latitude: 8.959927
      },
      {
        name: 'Betania',
        longitude: -79.526553,
        latitude: 9.012151
      },
      {
        name: 'Bella Vista',
        longitude: -79.526022,
        latitude: 8.983972
      },
      {
        name: 'Calidonia',
        longitude: -79.535817,
        latitude: 8.968804
      },
      {
        name: 'Curundú',
        longitude: -79.543629,
        latitude: 8.969860
      },
      {
        name: 'Don Bosco',
        longitude: -79.4153652,
        latitude: 9.0494445
      },
      {
        name: 'El Chorrillo',
        longitude: -79.543442,
        latitude: 8.950293
      },
      {
        name: 'Juan Diaz',
        longitude: -79.4589348,
        latitude: 9.036498
      },
      {
        name: 'Parque Lefevre',
        longitude: -79.491183,
        latitude: 9.011381
      },
      {
        name: 'Pueblo Nuevo',
        longitude: -79.513834,
        latitude: 9.008878
      },
      {
        name: 'Río Abajo',
        longitude: -79.491915,
        latitude: 9.024213
      },
      {
        name: 'San Felipe',
        longitude: -79.535048,
        latitude: 8.952410
      },
      {
        name: 'San Francisco',
        longitude: -79.507848,
        latitude: 8.992609
      },
      {
        name: 'Santa Ana',
        longitude: -79.540677,
        latitude: 8.956486
      },
      {
        name: 'Tocumen',
        longitude: -79.388304,
        latitude: 9.071253
      },
      {
        name: 'Costa Del Este',
        longitude: -79.471627,
        latitude: 9.013227
      }
    ]

    district_ids = []

    corregimientos.each do |corregimiento|
      district = Spree::District.find_or_initialize_by(name: corregimiento[:name], state_id: panama_state_id)
      district.update!(latitude: corregimiento[:latitude], longitude: corregimiento[:longitude])
      district_ids << district.id
    end

    Spree::District.where.not(id: district_ids).destroy_all
  end

  task :create_panama_zone do
    Rails.logger.info('Create Panama Zone')

    zone = Spree::Zone.find_or_create_by!(name: 'Panama')
    country = Spree::Country.find_by(name: 'Panama')
    Spree::ZoneMember.find_or_create_by!(zoneable_type: 'Spree::Country', zoneable_id: country.id, zone_id: zone.id)
  end

  task :create_panama_city_zones do
    Rails.logger.info('Create Panama City Zones')

    district_name_by_zones = {
      zone1: ['Bella Vista', 'Calidonia', 'Curundú', 'San Francisco'],
      zone2: ['Ancón', 'Betania', 'Costa Del Este', 'El Chorrillo', 'Parque Lefevre', 'Pueblo Nuevo', 'Río Abajo', 'San Felipe', 'Santa Ana'],
      zone3: ['24 de Diciembre', 'Don Bosco', 'Juan Diaz', 'Tocumen']
    }

    zone_member_ids = []
    3.times do |n|
      zone = Spree::Zone.find_or_create_by!(name: "Panama Zone #{n + 1}")
      districts = Spree::District.where(name: district_name_by_zones["zone#{n + 1}".to_sym])
      districts.each do |district|
        zone_member_ids << Spree::ZoneMember.find_or_create_by!(zoneable_type: 'Spree::District', zoneable_id: district.id, zone_id: zone.id).id
      end
    end

    Spree::ZoneMember.where(zoneable_type: 'Spree::District').where.not(id: zone_member_ids).destroy_all
  end

  task :create_tax_category do
    Rails.logger.info('Create ITBMS Tax Category and Tax Rate')

    itbms_tax_category = Spree::TaxCategory.find_or_create_by(repair_shopr_id: 39_011)
    itbms_tax_category.update!(name: 'ITBMS', is_default: true, tax_code: 'itbms')

    calculator = Spree::Calculator.create!(type: 'Spree::Calculator::DefaultTax', calculable_type: 'Spree::TaxRate')

    itbms_tax_rate = Spree::TaxRate.find_or_initialize_by(name: 'ITBMS')
    itbms_tax_rate.assign_attributes(
      amount: 0.07,
      zone_id: Spree::Zone.find_by!(name: 'Panama').id,
      included_in_price: false,
      show_rate_in_label: true
    )
    itbms_tax_rate.tax_categories = [itbms_tax_category]
    itbms_tax_rate.calculator = calculator
    itbms_tax_rate.save!
  end

  task :create_shipping_methods do
    Rails.logger.info('Create Panama City Shipping Methods by Zone')

    default_shipping_category = Spree::ShippingCategory.find_or_create_by!(name: 'Default')

    Spree::ShippingMethod.destroy_all

    Spree::Calculator::Shipping::CustomShippingCalculator.destroy_all

    amount_per_zone = {
      zone1: 3.9,
      zone2: 5.5,
      zone3: 9.5
    }

    3.times do |n|
      shipping_method = Spree::ShippingMethod.new(name: "Panama Zone #{n + 1}")
      zone = Spree::Zone.find_by!(name: "Panama Zone #{n + 1}")
      shipping_method.attributes = {
        shipping_categories: [default_shipping_category],
        zones: [zone],
        service_level: 'delivery',
        code: n + 1,
        admin_name: "panama_zone_#{n + 1}"
      }
      shipping_method.calculator = Spree::Calculator::Shipping::CustomShippingCalculator.new(preferences: { amount: amount_per_zone["zone#{n + 1}".to_sym] })
      shipping_method.save!
    end

    Rails.logger.info('Create Pick-up in Store Shipping Methods')

    Spree::Calculator::Shipping::FlatPercentItemTotal.destroy_all

    panama_zone = Spree::Zone.find_by(name: 'Panama')

    bella_vista_pickup = Spree::ShippingMethod.new(
      name: 'Pick-up in store: Bella Vista',
      shipping_categories: [default_shipping_category],
      zones: [panama_zone],
      admin_name: 'Bella Vista',
      latitude: 8.9805139,
      longitude: -79.5268223,
      google_map_link: 'https://g.page/SalvaMiMaquina?share'
    )
    bella_vista_pickup.calculator = Spree::Calculator::Shipping::FlatPercentItemTotal.new(preferences: { amount: 0 })
    bella_vista_pickup.save!

    san_francisco_pickup = Spree::ShippingMethod.new(
      name: 'Pick-up in store: San Francisco',
      shipping_categories: [default_shipping_category],
      zones: [panama_zone],
      admin_name: 'San Francisco',
      latitude: 8.9946759,
      longitude: -79.5018423,
      google_map_link: 'https://goo.gl/maps/vkQKG5ywQj5z2VqB8'
    )
    san_francisco_pickup.calculator = Spree::Calculator::Shipping::FlatPercentItemTotal.new(preferences: { amount: 0 })
    san_francisco_pickup.save!
  end

  task :destroy_countries_and_states_out_of_panama do
    Rails.logger.info('Destroy countries and states out of Panama')

    panama_id = Spree::Country.find_by(name: 'Panama').id

    Spree::Country.where.not(id: panama_id).destroy_all
    Spree::State.where.not(country_id: panama_id).destroy_all
  end

  task :create_payment_methods do
    Rails.logger.info('Create payment methods')

    Spree::PaymentMethod.destroy_all

    bac_credit_card = Spree::PaymentMethod.find_or_initialize_by(type: 'Spree::PaymentMethod::BacCreditCard', name: 'Credit Card')
    bac_credit_card.attributes = {
      preferences: { server: 'fac', test_mode: false },
      auto_capture: true
    }
    bac_credit_card.save!
  end

  task :create_free_shipping_promotion do
    Rails.logger.info('Create free shipping promotion')

    promotion = Spree::Promotion.find_or_create_by!(name: 'Entrega Gratis')
    promotion.apply_automatically = true
    promotion.description = 'free_shipping_threshold'
    promotion.actions.find_or_create_by!(type: 'Spree::Promotion::Actions::FreeShipping')
    promotion.rules.find_or_create_by(
      type: 'Spree::Promotion::Rules::ItemTotal',
      preferences: { amount: Spree::Promotion::FREE_SHIPPING_THRESHOLD, currency: 'USD', operator: 'gte' }
    )
    promotion.rules.find_or_create_by(
      type: 'Spree::Promotion::Rules::ShippingMethod'
    )
    promotion.save!
  end

  task :create_cross_sells_relation_type do
    Rails.logger.info('Create cross sells relation type')

    Spree::RelationType.find_or_create_by!(
      name: 'Cross Sells',
      applies_to: 'Spree::Product',
      applies_from: 'Spree::Product',
      bidirectional: true
    )
  end

  task :create_admin_spree_role do
    Rails.logger.info('Create admmin role')

    Spree::Role.find_or_create_by!(name: 'admin')
  end
end
# rubocop:enable Metrics/BlockLength
