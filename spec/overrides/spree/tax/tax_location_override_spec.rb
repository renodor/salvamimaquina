# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Tax::TaxLocation do
  let(:country) { create(:country) }
  let(:state) { create(:state) }
  let(:district) { create(:district) }
  let(:district2) { create(:district) }

  describe '#==' do
    it 'returns true if given Spre::Tax::TaxLocation has the same state, country and district' do
      tax_location = described_class.new(country: country, state: state, district: district)
      tax_location2 = described_class.new(country: country, state: state, district: district)
      tax_location3 = described_class.new(country: country, state: state, district: district2)

      expect(tax_location == tax_location2).to be true
      expect(tax_location == tax_location3).to be false
    end
  end

  describe '#empty?' do
    it 'returns true when country and state and district are nil or not persisted' do
      expect(described_class.new.empty?).to be true
      expect(described_class.new(district: build(:district)).empty?).to be true
      expect(described_class.new(district: district).empty?).to be false
    end
  end
end
