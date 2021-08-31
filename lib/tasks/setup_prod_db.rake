# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :setup_prod_db do
  task run: %i[
    environment
    create_stock_locations
    create_taxonomies
    create_panama_city_corregimientos
    create_panama_city_zones
    create_tax_category
    create_shipping_methods
    destroy_countries_and_states_out_of_panama
    create_payment_methods
    create_free_shipping_promotion
  ]

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
    brand_taxonomy = Spree::Taxonomy.find_or_create_by!(name: 'Brands', position: 1)
    brand_taxonomy.taxons.find_or_create_by(name: 'Brands', position: 1)

    Spree::Taxonomy.where.not(id: brand_taxonomy.id).destroy_all
  end

  task :create_panama_city_corregimientos do
    Rails.logger.info('Create Panama City corregimientos')
    panama_state_id = Spree::State.find_by(name: 'Panamá').id
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
        name: 'Rio Abajo',
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
      zone2: ['Ancón', 'Betania', 'Costa Del Este', 'El Chorrillo', 'Parque Lefevre', 'Pueblo Nuevo', 'Rio Abajo', 'San Felipe', 'Santa Ana'],
      zone3: ['24 de Diciembre', 'Don Bosco', 'Juan Diaz', 'Tocumen']
    }

    3.times do |n|
      zone = Spree::Zone.find_or_create_by!(name: "Panama Zone #{n + 1}")
      districts = Spree::District.where(name: district_name_by_zones["zone#{n + 1}".to_sym])
      districts.each do |district|
        Spree::ZoneMember.find_or_create_by!(zoneable_type: 'Spree::District', zoneable_id: district.id, zone_id: zone.id)
      end
    end
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
    default_shipping_category = Spree::ShippingCategory.find_by!(name: 'Default')

    Rails.logger.info('Create Panama City Shipping Methods by Zone')

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
        code: n + 1
      }
      shipping_method.calculator = Spree::Calculator::Shipping::CustomShippingCalculator.new(preferences: { amount: amount_per_zone["zone#{n + 1}".to_sym] })
      shipping_method.save!
    end

    Rails.logger.info('Create Pick-up in Store Shipping Methods')

    Spree::Calculator::Shipping::FlatPercentItemTotal.destroy_all
    ['Pick-up in store: Bella Vista', 'Pick-up in store: San Francisco'].each do |name|
      shipping_method = Spree::ShippingMethod.new(name: name)
      shipping_method.attributes = {
        shipping_categories: [default_shipping_category],
        zones: [Spree::Zone.find_by(name: 'Panama')],
        admin_name: name.split(': ').last,
      }
      shipping_method.calculator = Spree::Calculator::Shipping::FlatPercentItemTotal.new(preferences: { amount: 0 })
      shipping_method.save!
    end
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
    promotion = Spree::Promotion.find_or_create_by!(name: 'Free Shipping Threshold')
    promotion.actions.find_or_create_by!(type: 'Spree::Promotion::Actions::FreeShipping')
    promotion.rules.find_or_create_by(
      type: 'Spree::Promotion::Rules::ItemTotal',
      preferences: { amount: 150, currency: 'USD', operator: 'gte' }
    )
    promotion.save!
  end
end
# rubocop:enable Metrics/BlockLength
