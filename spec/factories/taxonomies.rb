# frozen_string_literal: true

FactoryBot.define do
  factory :taxonomy, class: 'Spree::Taxonomy' do
    name { 'Categories' }
  end
end
