# frozen_string_literal:true

module SliderHelper
  def slider_location_url(slider)
    slider_css_id = "#{slider.location}-slider"
    case slider.location
    when 'home_page'
      main_app.root_path(anchor: slider_css_id)
    when 'products'
      main_app.products_es_mx_path(anchor: slider_css_id)
    when 'trade_in'
      main_app.new_trade_in_request_path(anchor: slider_css_id)
    when 'reparation'
      main_app.reparation_categories_path(anchor: slider_css_id)
    when 'corporate_clients_1', 'corporate_clients_2'
      main_app.corporate_clients_path(anchor: slider_css_id)
    when 'about'
      main_app.about_path(anchor: slider_css_id)
    when 'contact'
      main_app.contact_path(anchor: slider_css_id)
    end
  end
end
