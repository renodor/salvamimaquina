# frozen_string_literal: true

module Spree
  module ImageDecorator
    CLOUDINARY_STORAGE_FOLDER = 'products'

    Spree::Image.prepend self
  end
end
