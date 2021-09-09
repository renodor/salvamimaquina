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
      (record.is_a?(Spree::Taxon) && record.parent.name == 'apple') ||
      (record.is_a?(Spree::Product) && Taxon.find_by(name: 'apple').all_products.include?(record)) # TODO: cache Apple taxon
    end
  end
end
