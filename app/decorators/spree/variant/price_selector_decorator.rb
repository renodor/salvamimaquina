# frozen_string_literal: true

module Spree::Variant::PriceSelectorDecorator
  # This method was calling Spree::Price#money which is built by the Spree::DisplayMoney module, and which calls Spree::Price#amount by default
  # However Spree::Price#amount always return the discounted price if variant is on sale...
  # So we need to add an optional argument to force to call Spree::Price#original_price,
  # and only call Spree::Price#price (which also returns the discounted price) when we want the discounted price
  # (In the process we also get rid of Spree::DisplayMoney and call Spree::Money.new directly)

  # BUT, at the end this module is usefull only if you have a multi-country, multy-currency store...
  # Which is not our case here, so I'll keep this decorator just in case, but we currently directly call Spree::Money in our views when we need to
  def price_for(price_options, sale_price: false)
    valid_price_record = variant.currently_valid_prices.detect do |price|
      (price.country_iso == price_options.desired_attributes[:country_iso] ||
        price.country_iso.nil?
      ) && price.currency == price_options.desired_attributes[:currency]
    end

    price = sale_price ? valid_price_record.price : valid_price_record.original_price
    Spree::Money.new(price, { currency: valid_price_record.currency })
  end

  Spree::Variant::PriceSelector.prepend self
end
