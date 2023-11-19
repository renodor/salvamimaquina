# frozen_string_literal:true

RouteTranslator.config do |config|
  config.generate_unnamed_unlocalized_routes = true
  config.hide_locale = true
  config.available_locales = %w[es-MX]
end
