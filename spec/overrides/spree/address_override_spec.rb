# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Address do
  let(:district) { create(:district) }
  let(:address) { create(:address, district: district, latitude: 1.234, longitude: 5.678) }

  it 'belongs to district' do
    expect(address.district).to eq(district)
  end

  it 'removes non numerical characters from phone before validation' do
    address.phone = '+123'
    address.valid?
    expect(address.phone).to eq('123')
  end

  describe '#require_zipcode?' do
    it 'doesnt require zipcode' do
      expect(address.require_zipcode?).to be false
    end
  end

  describe '#google_maps_link' do
    it 'builds google maps link with latitude and longitude' do
      expect(address.google_maps_link).to eq('http://www.google.com/maps/place/1.234,5.678')
    end
  end
end
