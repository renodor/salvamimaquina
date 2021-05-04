# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :setup_prod_db do
  task run: %i[
    environment
    create_stock_locations
    create_taxonomies
    create_zone create_tax_category
    create_panama_city_corregimientos
    destroy_countries_and_states_out_of_panama
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
    Spree::Taxonomy.find_or_create_by!(name: 'Categories').taxons.find_or_create_by!(name: 'Categories')
    Spree::Taxonomy.find_or_create_by!(name: 'Brands').taxons.find_or_create_by(name: 'Brands')
  end

  task :create_zone do
    Rails.logger.info('Create Panama Zone')
    panama = Spree::Country.find_by(name: 'Panama')
    panama_zone = Spree::Zone.find_or_create_by(name: 'Panama')
    Spree::ZoneMember.find_or_create_by(zoneable_type: panama.class.name, zoneable_id: panama.id, zone_id: panama_zone.id)
  end

  task :create_tax_category do
    Rails.logger.info('Create ITBMS Tax Category and Tax Rate')
    itbms_tax_category = Spree::TaxCategory.find_or_create_by(repair_shopr_id: 39_011)
    itbms_tax_category.update!(name: 'ITBMS', is_default: true, tax_code: 'itbms')

    calculator = Spree::Calculator.create!(type: 'Spree::Calculator::DefaultTax', calculable_type: 'Spree::TaxRate')

    itbms_tax_rate = Spree::TaxRate.find_or_initialize_by(name: 'ITBMS')
    itbms_tax_rate.assign_attributes(
      amount: 0.07,
      zone_id: Spree::Zone.find_by(name: 'Panama').id,
      included_in_price: false,
      show_rate_in_label: true
    )
    itbms_tax_rate.tax_categories = [itbms_tax_category]
    itbms_tax_rate.calculator = calculator
    itbms_tax_rate.save!
  end

  task :create_panama_city_corregimientos do
    Rails.logger.info('Create Panama City corregimientos')
    panama_state_id = Spree::State.find_by(name: 'Panamá').id
    corregimientos = [
      '24 de Diciembre',
      'Ancón',
      'Betania',
      'Bella Vista',
      'Calidonia',
      'Curundú',
      'Don Bosco',
      'El Chorrillo',
      'Juan Díaz',
      'Parque Lefevre',
      'Pueblo Nuevo',
      'Río Abajo',
      'San Felipe',
      'San Francisco',
      'Santa Ana',
      'Tocumen'
    ]
    district_ids = []

    corregimientos.each do |corregimiento|
      district = District.find_or_create_by!(name: corregimiento, state_id: panama_state_id)
      district_ids << district.id
    end

    District.where.not(id: district_ids).destroy_all
  end

  task :destroy_countries_and_states_out_of_panama do
    Rails.logger.info('Destroy countries and states out of Panama')

    panama_id = Spree::Country.find_by(name: 'Panama').id

    Spree::Country.where.not(id: panama_id).destroy_all
    Spree::State.where.not(country_id: panama_id).destroy_all
  end
end
# rubocop:enable Metrics/BlockLength
