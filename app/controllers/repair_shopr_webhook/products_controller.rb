class RepairShoprWebhook::ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :authenticate

  def product_updated
    return unless params['link'].include?('https://coolshop.repairshopr.com/products/')

    attributes = params['attributes']
    Spree::Product.transaction do
      product = Spree::Product.find_or_initialize_by(repair_shopr_id: attributes['id'])
      product.price = attributes['price_retail']
      product.name = attributes['name']
      product.shipping_category_id = Spree::ShippingCategory.find_by(name: 'Default').id
      product.save!
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      # Compare the tokens in a time-constant manner, to mitigate timing attacks.
      ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.credentials.repair_shopr_api_key)
    end
  end
end

#    payload_example = {"text"=>"A Product was updated\n\nProduct Labor was changed", "html"=>"A Product was updated \n\n Product Labor was changed", "link"=>"https://coolshop.repairshopr.com/products/13432927", "attributes"=>{"id"=>13432927, "price_cost"=>15.0, "price_retail"=>70.34, "condition"=>"", "description"=>"Labor", "maintain_stock"=>false, "name"=>"Labor", "quantity"=>0, "warranty"=>nil, "sort_order"=>nil, "reorder_at"=>nil, "disabled"=>false, "taxable"=>true, "product_category"=>nil, "category_path"=>nil, "upc_code"=>"", "discount_percent"=>nil, "warranty_template_id"=>nil, "qb_item_id"=>nil, "desired_stock_level"=>nil, "price_wholesale"=>0.0, "notes"=>"", "tax_rate_id"=>nil, "physical_location"=>"", "serialized"=>false, "vendor_ids"=>[], "long_description"=>nil, "location_quantities"=>[]}, "controller"=>"repair_shopr_webhook/products", "action"=>"product_updated", "product"=>{"text"=>"A Product was updated\n\nProduct Labor was changed", "html"=>"A Product was updated \n\n Product Labor was changed", "link"=>"https://coolshop.repairshopr.com/products/13432927", "attributes"=>{"id"=>13432927, "price_cost"=>15.0, "price_retail"=>70.34, "condition"=>"", "description"=>"Labor", "maintain_stock"=>false, "name"=>"Labor", "quantity"=>0, "warranty"=>nil, "sort_order"=>nil, "reorder_at"=>nil, "disabled"=>false, "taxable"=>true, "product_category"=>nil, "category_path"=>nil, "upc_code"=>"", "discount_percent"=>nil, "warranty_template_id"=>nil, "qb_item_id"=>nil, "desired_stock_level"=>nil, "price_wholesale"=>0.0, "notes"=>"", "tax_rate_id"=>nil, "physical_location"=>"", "serialized"=>false, "vendor_ids"=>[], "long_description"=>nil, "location_quantities"=>[]}}}