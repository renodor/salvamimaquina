# frozen_string_literal:true

module CloudinaryLinksWithFoldersHelper
  def cl_image_path_with_folder(image, options = {})
    cl_image_path(image_url(image), options)
  end

  def cl_image_tag_with_folder(image, options = {})
    cl_image_tag(image_url(image), options)
  end

  private

  def image_url(image)
    return '' unless image.try(:key)

    "#{Rails.env}/#{image.record.class::CLOUDINARY_STORAGE_FOLDER}/#{image.key}"
  end
end
