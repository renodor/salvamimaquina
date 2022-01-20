# frozen_string_literal:true

module CloudinaryLinksWithFoldersHelper
  def cl_image_path_with_folder(image, options = {})
    cl_image_path(image_url(image, options), options_with_folder(options))
  end

  def cl_image_tag_with_folder(image, options = {})
    cl_image_tag(image_url(image, options), options_with_folder(options))
  end

  private

  def image_url(image, options)
    # If we want cloudinary fallback image to work we need to return a "wrong" image key (like "_")
    # otherwise we can return an empty string and the image won't be processed at all
    return options[:no_fallback] ? '' : '0' unless image.try(:key)

    "#{Rails.env}/#{options[:model]::CLOUDINARY_STORAGE_FOLDER}/#{image.key}"
  end

  def options_with_folder(options)
    return options unless options[:model].const_defined?('CLOUDINARY_FALLBACK_IMAGE')

    options[:default_image] = "#{Rails.env}:#{options[:model]::CLOUDINARY_STORAGE_FOLDER}:#{options[:model]::CLOUDINARY_FALLBACK_IMAGE}"
    options
  end
end
