# frozen_string_literal: true

FactoryBot.define do
  factory :option_type, class: 'Spree::OptionType' do
    sequence(:name) { |n| "option type #{n}" }
    sequence(:presentation) { |n| "option type #{n}" }
  end
end
