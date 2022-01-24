# frozen_string_literal: true

# Copying the whole Taxon::ActiveStorageAttachment module ONLY to pass a 3rd argument to the has_attachment method.
# TODO: find a way to modify this without having to copy the whole module

module Spree::Taxon::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter

  included do
    has_attachment(
      :icon,
      {
        styles: {
          mini: '32x32>',
          normal: '128x128>'
        },
        default_style: :mini
      },
      'cloudinary_product_categories' # storage service name
    )
    validate :icon_is_an_image
  end
end
