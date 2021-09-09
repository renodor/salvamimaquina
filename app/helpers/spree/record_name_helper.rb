# frozen_string_literal: true

module Spree
  module RecordNameHelper
    def branded_name(record)
      name = record.name
      if is_an_apple_record?(record) && name.starts_with?('i')
        name.capitalize_second_letter
      else
        name.split.map(&:capitalize).join
      end
    end

    def is_an_apple_record?(record)
      apple_taxon = Spree::Taxon.where(name: ['apple', 'Apple']).first # TODO: cache that and improve the logic
      return false unless apple_taxon

      (record.is_a?(Spree::Taxon) && record.parent == apple_taxon) ||
      (record.is_a?(Spree::Product) && apple_taxon.all_products.include?(record)) 
    end
  end
end
