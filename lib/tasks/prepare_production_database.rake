# frozen_string_literal: true

namespace :production_setup do
  task create_stock_locations: :environment do
    Rails.logger.info('Started create_stock_locations task')

    Spree::StockLocation.find_or_initialize_by(repair_shopr_id: 1928).update!(
      name: 'Bella Vista',
      backorderable_default: false
    )

    Spree::StockLocation.find_or_initialize_by(repair_shopr_id: 1927).update!(
      name: 'San Francisco',
      backorderable_default: false
    )

    Spree::StockLocation.where.not(repair_shopr_id: [1928, 1927]).destroy_all

    Rails.logger.info("#{Spree::StockLocation.count} stock_locations created")
    Rails.logger.info('Finished create_stock_locations task')
  end

  task create_taxonomy: :environment do
    Spree::Taxonomy.find_or_create_by(name: 'Categories')
  end

  task create_tax_category: :environment do
    itbms_tax_category = Spree::TaxCategory.find_or_create_by(repair_shopr_id: 39_011)
    itbms_tax_category.update!(name: 'ITBMS', is_default: true, tax_code: 'itbms')

    itbms_tax_rate = Spree::TaxRate.find_or_create_by(name: 'ITBMS')
    itbms_tax_rate.update!(amout: 0.07)
    # TO FINISH
  end
end
