# frozen_string_literal:true

# Dinamically create storage service for the following folders.
# (Then we need to choose what model will have an attachment using those services)

# For example, adding "slides" in the folder list here will create the following service:
# cloudinary_slides: {
#   service: 'Cloudinary',
#   folder: '{{ Rails.env }}/slides'
# }
# So on the Slide model we can now define:
# has_one_attached :image, service: :cloudinary_slides
# Now each time an attachment is create for Slide model, the image will be automatically uploaded in Cloudinary in the following folder:
# - /development/slides (in dev environment)
# - /production/slides (in prod environment)

# (Then when displaying images on the front end don't forget to use #cl_image_path_with_folder and #cl_image_tag_with_folder methods
# to retrieve the files on the correct folder)

folders = %w[products product_categories slides banners reparation_categories]

service_configuration = {}
folders.each do |folder|
  service_configuration["cloudinary_#{folder}"] = { 'service' => 'Cloudinary', 'folder' => "#{Rails.env}/#{folder}" }
end

Rails.configuration.active_storage.service_configurations = service_configuration
