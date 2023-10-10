# frozen_string_literal: true

class RepairShoprApi::V1::SyncProductCategories < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      # Product categories (taxons) all belong to one parent taxon named "Categories",
      # that itself belong to one parent taxonomy names "Categories"
      @categories_taxonomy = Spree::Taxonomy.find_by(name: 'Categories') || raise('Categories Taxonomy is needed')
      @root_taxon = Spree::Taxon.find_by(depth: 0, taxonomy_id: @categories_taxonomy.id) || raise('Root Taxon is needed')

      # Fetch all product categories from RepairShopr
      # (Only the categories below the root category "ecom" will be returned)
      product_categories = get_product_categories

      Rails.logger.info('Start to sync product categories')

      taxons_and_parents = create_or_update_taxons_and_flatten_hierarchy(product_categories)
      taxon_ids = update_taxons_hierarchy(taxons_and_parents)

      # All taxons, belonging to categories taxonomy, that are not present in the taxon_ids array or is not the categories_taxon
      # need to be deleted (It means they have been deleted from RepairShopr)
      deleted_taxons = @categories_taxonomy.taxons.where.not(id: taxon_ids + [@root_taxon.id]).destroy_all

      sync_logs.synced_product_categories = taxon_ids.size
      sync_logs.deleted_product_categories = deleted_taxons.size

      Rails.logger.info('Product categories synced')

      taxon_ids
    rescue => e # rubocop:disable Style/RescueStandardError
      sync_logs.sync_errors << { product_categories_error: e.message }
      false
    ensure
      sync_logs.status = sync_logs.sync_errors.any? ? 'error' : 'complete'
      sync_logs.save!

      Sentry.capture_message(name, { extra: { sync_logs_errors: sync_logs.sync_errors } }) if sync_logs.sync_errors.any?
    end

    # First find or create taxons from RepairShopr product categories
    # and for each product categories return an hash with its corresponding taxon and its product category parent
    # (We need this first step because we can't put a taxon below a parent that does not exist yet...)
    def create_or_update_taxons_and_flatten_hierarchy(product_categories)
      product_categories.map do |product_category|
        taxon = Spree::Taxon.find_or_initialize_by(repair_shopr_id: product_category['id'], taxonomy_id: @categories_taxonomy.id)
        taxon.update!(name: product_category['name'], description: product_category['description'])
        # Product category without "/" in ancestry has only one ancester, which is necessarly the root category "ecom"
        # So in our current hierarchy, it will be directly under the @root_taxon
        { taxon: taxon, parent: product_category['ancestry'].include?('/') ? product_category['ancestry'] : nil }
      end
    end

    # For each taxon, find its taxon parent and move it under it to create the correct hierarchy
    # Then simply return taxon id (we use it after that to identify what taxon need to be deleted)
    def update_taxons_hierarchy(taxons_and_parents)
      taxons_and_parents.map do |taxon_and_parent|
        if taxon_and_parent[:parent]
          taxon_parent = Spree::Taxon.find_by(repair_shopr_id: taxon_and_parent[:parent].split('/').last.to_i)
          taxon_and_parent[:taxon].update!(parent: taxon_parent)
        else
          taxon_and_parent[:taxon].update!(parent: @root_taxon)
        end

        taxon_and_parent[:taxon].id
      end
    end
  end
end
