# frozen_string_literal: true

module Spree
  module TaxonsNameHelper
    def branded_name(record)
      name = record.name
      return name unless record.is_a?(Spree::Taxon)

      if record.parent.name == 'apple' && name.starts_with?('i')
        name.capitalize_second_letter
      else
        name.capitalize
      end
    end
  end
end
