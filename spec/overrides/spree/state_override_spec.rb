# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::State do
  let(:state) { create(:state) }
  let!(:district) { create(:district, name: 'Cool distrcit', state: state) }
  let!(:district2) { create(:district, name: 'Cool distrcit 2', state: state) }

  it 'has many districts ordered by name' do
    expect(state.districts).to eq([district, district2])
  end

  it 'destroys districts when destroying state' do
    state.destroy!

    expect { district.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { district2.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
