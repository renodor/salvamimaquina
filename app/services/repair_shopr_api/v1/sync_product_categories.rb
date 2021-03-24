# frozen_string_literal: true

class RepairShoprApi::V1::SyncProductCategories < RepairShoprApi::V1::Base
  class << self
    def call
      @categories_taxonomy_id = Spree::Taxonomy.find_by(name: 'Categories').id
      @categories_taxon = Spree::Taxon.find_by(name: 'Categories')

      product_categories = get_product_categories['categories']

      Rails.logger.info('Start to sync product categories')
      Spree::Taxon.transaction do
        taxons = create_or_update_taxons_and_flatten_hierarchy(product_categories)
        update_taxons_hierarchy(taxons, product_categories)
        delete_removed_product_categories(product_categories.map { |product_category| product_category['id'] })
      end
      Rails.logger.info('Product categories synced')
    end

    def create_or_update_taxons_and_flatten_hierarchy(product_categories)
      product_categories.map do |product_category|
        taxon = Spree::Taxon.find_or_initialize_by(repair_shopr_id: product_category['id'], taxonomy_id: @categories_taxonomy_id)
        taxon.update!(name: product_category['name'], description: product_category['description'])
        taxon.move_to_child_of(@categories_taxon)
        taxon
      end
    end

    def update_taxons_hierarchy(taxons, product_categories)
      product_categories.each do |product_category|
        next unless product_category['ancestry']

        taxon = taxons.detect { |t| t.repair_shopr_id == product_category['id'] }
        taxon_parent = taxons.detect { |t| t.repair_shopr_id == product_category['ancestry'].split('/').last.to_i }
        taxon.move_to_child_of(taxon_parent)
      end
    end

    def delete_removed_product_categories(product_category_ids)
      Spree::Taxon.all.each do |taxon|
        taxon.destroy! unless taxon == @categories_taxon || product_category_ids.include?(taxon.repair_shopr_id)
      end
    end
  end
end
