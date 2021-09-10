# frozen_string_literal: true

module Spree
  module NameHelper
    def branded_name(name)
      # TODO: transform this array to regex
      if %w[iphone iphones ipad ipads imac imacs iwatch iwatchs iwatches].include?(name.split.first.downcase)
        name.capitalize_second_letter
      else
        name.split.map(&:capitalize).join(' ')
      end
    end
  end
end
