# frozen_string_literal:true

model_names = %w[products product_categories slides banners reparation_categories]

service_configuration = {}
model_names.each do |model_name|
  service_configuration["cloudinary_#{model_name}"] = { 'service' => 'Cloudinary', 'folder' => "#{Rails.env}/#{model_name}" }
end

Rails.configuration.active_storage.service_configurations = service_configuration
