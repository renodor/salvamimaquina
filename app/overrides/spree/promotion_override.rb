# frozen_string_literal:true

module Spree
  module PromotionOverride
    FREE_SHIPPING_THRESHOLD = 150

    Spree::Promotion.prepend self
  end
end
