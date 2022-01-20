# frozen_string_literal: true

module Spree
  module ImageDecorator
    CLOUDINARY_STORAGE_FOLDER = 'products'
    CLOUDINARY_FALLBACK_IMAGE = 'product-image-placeholder.jpg'

    Spree::Image.prepend self
  end
end
