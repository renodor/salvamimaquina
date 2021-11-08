# frozen_string_literal: true

json.call(image, *image_attributes)
json.call(image, :viewable_type, :viewable_id)
# TODO: key here will represent all image styles/sizes (:mini, :small, :large etc...)
# And we are supposed to retrieve product image for all of these sizes, but those are currently not configured in our Cloudinary account.
# Because this file is (I think??) only used on admin, this is not important right now.
Spree::Image.attachment_definitions[:attachment][:styles].each do |_key, _value|
  json.set! cl_image_path(image.attachment.key)
end
