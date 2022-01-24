# frozen_string_literal: true

# Copying the whole Image::ActiveStorageAttachment module ONLY to pass a 3rd argument to the has_attachment method.
# TODO: find a way to modify this without having to copy the whole module

module Spree::Image::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter

  delegate :width, :height, to: :attachment, prefix: true

  included do
    has_attachment(
      :attachment,
      {
        styles: {
          mini: '48x48>',
          small: '400x400>',
          product: '680x680>',
          large: '1200x1200>'
        },
        default_style: :product
      },
      'cloudinary_products' # storage service name
    )
    validates :attachment, presence: true
    validate :attachment_is_an_image
  end
end
