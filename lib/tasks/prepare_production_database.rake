namespace :prepare_production_database do
  task create_repair_shopr_stock_locations: :environment do
    Rails.logger.info('Started create_repair_shopr_stock_locations task')

    Spree::StockLocation.find_or_initialize_by(id: 1).update!(
      name: 'Bella Vista',
      repair_shopr_id: 1928,
      backorderable_default: false
    )

    Spree::StockLocation.find_or_initialize_by(id: 2).update!(
      name: 'San Francisco',
      repair_shopr_id: 1927,
      backorderable_default: false
    )

    Rails.logger.info('Finished create_repair_shopr_stock_locations task')
  end
end
