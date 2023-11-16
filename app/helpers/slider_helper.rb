# frozen_string_literal:true

module SliderHelper
  def slider_location_url(slider)
    slider_css_id = "#{slider.location}-slider"
    case slider.location
    when 'home_page'
      root_path(anchor: slider_css_id)
    when 'products'
      products_es_mx_path(anchor: slider_css_id)
    when 'trade_in'
      new_trade_in_request_path(anchor: slider_css_id)
    when 'reparation'
      reparation_categories_path(anchor: slider_css_id)
    when 'corporate_clients_1', 'corporate_clients_2'
      corporate_clients_path(anchor: slider_css_id)
    when 'about'
      about_path(anchor: slider_css_id)
    when 'contact'
      contact_path(anchor: slider_css_id)
    end
  end
end