# frozen_string_literal: true

FactoryBot.define do
  factory :cross_sell_relation_type, class: Spree::RelationType do
    name { 'cross_sell' }
    applies_from { 'Spree::Product' }
    applies_to { 'Spree::Product' }
  end
end
