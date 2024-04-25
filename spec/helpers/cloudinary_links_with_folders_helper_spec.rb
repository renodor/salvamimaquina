# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe CloudinaryLinksWithFoldersHelper, type: :helper do
  let(:image) { create(:image) }

  describe '#cl_image_path_with_folder' do
    it 'returns cloudinary path with folder and fallback image when key can be extracted from given record' do
      expect(helper.cl_image_path_with_folder(image.attachment, { model: Spree::Image }))
        .to eq("https://cloudinary.com/salvamimaquina/image/upload/d_test:products:product-image-placeholder.jpg/v1/test/products/#{image.attachment.key}")
    end

    it 'returns cloudinary path with a wrong URL and fallback image when key cannot be extracted from given record' do
      expect(helper.cl_image_path_with_folder(image, { model: Spree::Image }))
        .to eq('https://cloudinary.com/salvamimaquina/image/upload/d_test:products:product-image-placeholder.jpg/0')
    end

    it 'returns an empty string when key cannot be extracted from given record and no_fallback option is true' do
      expect(helper.cl_image_path_with_folder(image, { model: Spree::Image, no_fallback: true })).to eq('')
    end

    it 'returns cloudinary path with folder and no fallback image when given record doesnt have a fallback image defined' do
      stub_const('Spree::Image::CLOUDINARY_FALLBACK_IMAGE', '')
      expect(helper.cl_image_path_with_folder(image.attachment, { model: Spree::Image }))
        .to eq("https://cloudinary.com/salvamimaquina/image/upload/v1/test/products/#{image.attachment.key}")
    end
  end

  describe '#cl_image_tag_with_folder' do
    it 'returns cloudinary tag with folder and fallback image when key can be extracted from given record' do
      expect(helper.cl_image_tag_with_folder(image.attachment, { model: Spree::Image }))
        .to eq("<img model=\"Spree::Image\" src=\"https://cloudinary.com/salvamimaquina/image/upload/d_test:products:product-image-placeholder.jpg/v1/test/products/#{image.attachment.key}\" />")
    end

    it 'returns cloudinary tag with a wrong URL and fallback image when key cannot be extracted from given record' do
      expect(helper.cl_image_tag_with_folder(image, { model: Spree::Image }))
        .to eq('<img model="Spree::Image" src="https://cloudinary.com/salvamimaquina/image/upload/d_test:products:product-image-placeholder.jpg/0" />')
    end

    it 'returns an empty string when key cannot be extracted from given record and no_fallback option is true' do
      expect(helper.cl_image_tag_with_folder(image, { model: Spree::Image, no_fallback: true })).to eq('<img model="Spree::Image" no_fallback="true" ssl_detected="false" src="" />')
    end

    it 'returns cloudinary tag with folder and no fallback image when given record doesnt have a fallback image defined' do
      stub_const('Spree::Image::CLOUDINARY_FALLBACK_IMAGE', '')
      expect(helper.cl_image_tag_with_folder(image.attachment, { model: Spree::Image }))
        .to eq("<img model=\"Spree::Image\" src=\"https://cloudinary.com/salvamimaquina/image/upload/v1/test/products/#{image.attachment.key}\" />")
    end
  end
end
