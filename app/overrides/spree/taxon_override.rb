# frozen_string_literal: true

module Spree
  module TaxonOverride
    CLOUDINARY_STORAGE_FOLDER = 'product_categories'
    CLOUDINARY_FALLBACK_IMAGE = 'product-category-placeholder.jpg'

    Spree::Taxon.prepend self
  end
end
