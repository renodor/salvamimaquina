# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Stock::SimpleCoordinator do
  describe '#build_shipments' do
    let!(:bella_vista_stock_location) { create(:smm_stock_location, :bella_vista) }
    let!(:san_fracisco_stock_location) { create(:smm_stock_location, :san_francisco) }
    let(:zone) { create(:zone) }
    let(:country) { create(:country) }
    let!(:zone_member) { create(:zone_member, zoneable: country, zone: zone) }
    let(:address) { create(:address, country: country) }
    let(:variant) { create(:base_variant) }
    let!(:shipping_method) { create(:smm_shipping_method, :with_delivery, shipping_categories: [variant.shipping_category], zones: [zone]) }
    let(:order) { create(:order, ship_address: address) }
    let!(:line_item) { create(:line_item, quantity: 2, variant: variant, order: order) }

    it 'sets package_index for each packages of the shipment' do
      variant.stock_items.each { |stock_item| stock_item.set_count_on_hand(1) }

      shipments = described_class.new(order).shipments

      # We set package_index so that Spree::Calculator::Shipping::CustomShippingCalculator
      # can correctly set price to first package and zero to others.
      # So best way to check that package_index is correctly set, is to create shipments and check prices are correct
      expect(shipments[0].shipping_rates.sum(&:cost) > 0).to be true
      expect(shipments[1].shipping_rates.sum(&:cost)).to eq(0)
    end
  end
end
