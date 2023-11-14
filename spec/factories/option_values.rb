# frozen_string_literal: true

FactoryBot.define do
  factory :option_value, class: 'Spree::OptionValue' do
    option_type

    sequence(:name) { |n| "option value #{n}" }
    sequence(:presentation) { |n| "option value #{n}" }
  end
end
