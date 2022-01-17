# frozen_string_literal: true

module Spree
  module TaxonDecorator
    CLOUDINARY_STORAGE_FOLDER = 'product_categories'

    Spree::Taxon.prepend self
  end
end
