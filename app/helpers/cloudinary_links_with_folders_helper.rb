# frozen_string_literal:true

# Extend Cloudinary helper methods to use folders and fallback images.

# Folders:
# - A CLOUDINARY_STORAGE_FOLDER constant need to be defined on the model with the folder of the service
# - when using #cl_image_path_with_folder or #cl_image_tag_with_folder, the model name need to be added to the options argument
# For example:
# For Slide model, We want to use the cloudinary_slides service. This service folder is 'slides',
# so on the Slide model we defined CLOUDINARY_STORAGE_FOLDER = 'slides'
# Then when displaying a slide image we call: cl_image_tag(slide_image, model: Slide)

# Fallback images:
# - A fallback image need to be uploaded to Cloudinary in the correct folder
# - A CLOUDINARY_FALLBACK_IMAGE constant need to be defined on the model with the correct fallback image file name
# For example:
# For Slide model, we uploaded a fallback image with the name 'slide-placeholder.jpg' on the {{ Rails.env }}/slides folder,
# so on the Slide model we defined CLOUDINARY_FALLBACK_IMAGE = 'slide-placeholder.jpg'
# Now when displaying a slide image, if the file cannot be found, Cloudinary will automatically fallback to slide-placeholder.jpg image
# (Except if no_fallback is added to the options argument. Ex: cl_image_tag_with_folder(slide_image, model: Slide, no_fallback: true) )

module CloudinaryLinksWithFoldersHelper
  def cl_image_path_with_folder(image, options = {})
    cl_image_path(image_url(image, options), options_with_fallback_image(options))
  end

  def cl_image_tag_with_folder(image, options = {})
    cl_image_tag(image_url(image, options), options_with_fallback_image(options))
  end

  private

  def image_url(image, options)
    # If we want cloudinary fallback image to work we need to return a "wrong" image key (like "_")
    # otherwise we can return an empty string and the image won't be processed at all
    return options[:no_fallback] ? '' : '0' unless image.try(:key)

    "#{Rails.env}/#{options[:model]::CLOUDINARY_STORAGE_FOLDER}/#{image.key}"
  end

  def options_with_fallback_image(options)
    return options unless options[:model].const_defined?('CLOUDINARY_FALLBACK_IMAGE')

    options[:default_image] = "#{Rails.env}:#{options[:model]::CLOUDINARY_STORAGE_FOLDER}:#{options[:model]::CLOUDINARY_FALLBACK_IMAGE}"
    options
  end
end
