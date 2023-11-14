# frozen_string_literal: true

FactoryBot.define do
  factory :taxon, class: 'Spree::Taxon' do
    taxonomy

    name { 'Taxon' }

    trait :root do
      name { 'Categories' }
    end
  end
end
