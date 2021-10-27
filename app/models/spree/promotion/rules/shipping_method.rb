# frozen_string_literal:true

module Spree
  class Promotion
    module Rules
      class ShippingMethod < Spree::PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        # For now we went on the simplest way to implement that,
        # the correct way would be for this promotion rule to "have_many" shipping_methods,
        # and to be able to select one or many shipping method in the admin view of this rule.
        def eligible?(order, _options = {})
          %w[panama_zone_1 panama_zone_2].include?(order.shipments&.first&.shipping_method&.admin_name)
        end
      end
    end
  end
end
