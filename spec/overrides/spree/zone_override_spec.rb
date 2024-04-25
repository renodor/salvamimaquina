# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Zone do
  context 'scopes' do
    describe 'with_member_ids' do
      let(:zone) { create(:zone) }
      let(:zone2) { create(:zone) }
      let(:zone3) { create(:zone) }
      let(:zone4) { create(:zone) }
      let(:state) { create(:state) }
      let(:state2) { create(:state) }
      let(:state3) { create(:state) }
      let(:state4) { create(:state) }
      let(:country) { create(:country) }
      let(:district) { create(:district) }
      let!(:zone_member) { create(:zone_member, zoneable: state, zone: zone) }
      let!(:zone_member2) { create(:zone_member, zoneable: state2, zone: zone) }
      let!(:zone_member3) { create(:zone_member, zoneable: state3, zone: zone2) }
      let!(:zone_member4) { create(:zone_member, zoneable: state4, zone: zone3) }
      let!(:zone_member5) { create(:zone_member, zoneable: country, zone: zone3) }
      let!(:zone_member6) { create(:zone_member, zoneable: district, zone: zone4) }

      it 'returns zones with members from the given state ids' do
        expect(described_class.with_member_ids([state.id, state2.id, state3.id], nil, nil)).to contain_exactly(zone, zone2)
      end

      it 'returns zones with members from the given state ids or country ids' do
        expect(described_class.with_member_ids(state.id, country.id, nil)).to contain_exactly(zone, zone3)
      end

      it 'returns zones with members from the given state ids, country ids or district ids' do
        expect(described_class.with_member_ids(state.id, country.id, district.id)).to contain_exactly(zone, zone3, zone4)
      end

      it 'returns an empty association when no ids is given' do
        expect(described_class.with_member_ids([], nil, [])).to eq([])
      end
    end

    describe 'for_address' do
      let(:zone) { create(:zone) }
      let(:zone2) { create(:zone) }
      let(:zone3) { create(:zone) }
      let(:country) { create(:country) }
      let(:state) { create(:state) }
      let(:state2) { create(:state, country: country) }
      let(:state3) { create(:state) }
      let(:district) { create(:district) }
      let!(:address) { create(:address, state: state) }
      let!(:address2) { create(:address, state: state2, country: country) }
      let!(:address3) { create(:address, state: state3, district: district) }
      let!(:zone_member) { create(:zone_member, zoneable: state, zone: zone) }
      let!(:zone_member2) { create(:zone_member, zoneable: country, zone: zone2) }
      let!(:zone_member3) { create(:zone_member, zoneable: district, zone: zone3) }

      it 'returns zones with members from the given address state' do
        expect(described_class.for_address(address)).to eq([zone])
      end

      it 'returns zones with members from the given address country' do
        expect(described_class.for_address(address2)).to eq([zone2])
      end

      it 'returns zones with members from the given address district' do
        expect(described_class.for_address(address3)).to eq([zone3])
      end

      it 'returns an empty association when no address' do
        expect(described_class.for_address(nil)).to eq([])
      end
    end
  end

  describe '#district_ids' do
    let(:zone) { create(:zone) }

    context 'when zone members are districts' do
      let(:district) { create(:district) }
      let(:district2) { create(:district) }
      let!(:zone_member) { create(:zone_member, zoneable: district, zone: zone) }
      let!(:zone_member2) { create(:zone_member, zoneable: district2, zone: zone) }

      it 'returns district ids' do
        expect(zone.district_ids).to contain_exactly(district.id, district2.id)
      end
    end

    context 'when zone members are not districts' do
      let(:state) { create(:state) }
      let(:state2) { create(:state) }
      let!(:zone_member) { create(:zone_member, zoneable: state, zone: zone) }
      let!(:zone_member2) { create(:zone_member, zoneable: state2, zone: zone) }

      it 'returns an empty array' do
        expect(zone.district_ids).to eq([])
      end
    end
  end

  describe '#district_ids=' do
    let(:zone) { create(:zone) }
    let(:district) { create(:district) }
    let(:district2) { create(:district) }
    let(:district3) { create(:district) }
    let!(:zone_member) { create(:zone_member, zoneable: district, zone: zone) }

    it 'sets given district ids records as the new zone members' do
      expect(zone.members.map(&:zoneable)).to eq([district])

      zone.district_ids = [district2.id, district3.id]

      expect(zone.reload.members.map(&:zoneable)).to contain_exactly(district2, district3)
    end
  end
end
