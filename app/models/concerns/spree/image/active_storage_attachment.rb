# frozen_string_literal: true

# Copying the whole Image::ActiveStorageAttachment module ONLY to pass a 3rd argument to the has_attachment method.
# TODO: find a way to modify this without having to copy the whole module

module Spree::Image::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter

  delegate :width, :height, to: :attachment, prefix: true

  included do
    validates :attachment, presence: true
    validate :attachment_is_an_image
    validate :supported_content_type

    has_attachment :attachment,
                   styles: Spree::Config.product_image_styles,
                   default_style: Spree::Config.product_image_style_default,
                   service_name: 'cloudinary_products'

    def supported_content_type
      unless attachment.content_type.in?(Spree::Config.allowed_image_mime_types)
        errors.add(:attachment, :content_type_not_supported)
      end
    end
  end
end