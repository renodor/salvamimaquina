# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Stock::Package do
  describe '#initialize' do
    let(:stock_location) { create(:stock_location) }

    it 'accepts a third package_index argument with getter and setter properties' do
      package = described_class.new(stock_location, [], 2)

      expect(package.package_index).to eq(2)

      package.package_index = 1
      expect(package.package_index).to eq(1)
    end

    it 'has a third package_index argument null by default' do
      expect(described_class.new(stock_location, []).package_index).to be nil
    end
  end
end
