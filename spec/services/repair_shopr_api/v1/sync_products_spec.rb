# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepairShoprApi::V1::SyncProducts, type: :service do
  subject { described_class.call(sync_logs: sync_logs) }

  let(:sync_logs) { create(:repair_shopr_products_sync_log) }
  let(:fake_product) { { 'id' => '1111' } }
  let(:fake_product2) { { 'id' => '2222' } }
  let(:fake_product3) { { 'id' => '3333' } }

  before do
    allow(RepairShoprApi::V1::Base).to receive(:get_products).and_return([fake_product, fake_product2, fake_product3])
    allow(RepairShoprApi::V1::SyncProduct).to receive(:call)
  end

  it 'logs infos' do
    expect(Rails.logger).to receive(:info).with('Start to sync products')
    expect(Rails.logger).to receive(:info).with('Products synced')

    subject
  end

  it 'fetches products and call RepairShoprApi::V1::SyncProduct for all of them' do
    expect(RepairShoprApi::V1::Base).to receive(:get_products)
    expect(RepairShoprApi::V1::SyncProduct).to receive(:call).with({ attributes: fake_product, sync_logs: sync_logs })
    expect(RepairShoprApi::V1::SyncProduct).to receive(:call).with({ attributes: fake_product2, sync_logs: sync_logs })
    expect(RepairShoprApi::V1::SyncProduct).to receive(:call).with({ attributes: fake_product3, sync_logs: sync_logs })

    subject
  end

  context 'variants that have been destroyed from Repair Shopr' do
    let(:product) { create(:product) }
    let(:product2) { create(:product) }
    let!(:variant) { create(:variant, repair_shopr_id: '3333', product: product) }
    let!(:variant2) { create(:variant, repair_shopr_id: '4444', product: product) }
    let!(:variant3) { create(:variant, repair_shopr_id: nil, product: product2) }

    it 'destroys it and destroy product that had no other variants' do
      expect { subject }.to change(Spree::Product, :count).by(-1).and change(Spree::Variant, :count).by(-3)

      expect(product.reload.deleted_at).to be nil
      expect(variant.reload.deleted_at).to be nil
      expect(variant2.reload.deleted_at).not_to be nil
      expect(variant3.reload.deleted_at).not_to be nil
      expect(product2.reload.deleted_at).not_to be nil
    end

    it 'update sync logs deleted_products count' do
      expect { subject }.to change(sync_logs, :deleted_products).from(0).to(2)
    end
  end

  context 'when some taxons are not associated to any product anymore' do
    let!(:taxonomy) { create(:taxonomy) }
    let!(:taxon) { create(:taxon, parent: Spree::Taxon.root, taxonomy: taxonomy) }
    let!(:product) { create(:product, taxons: [taxon]) }
    let!(:variant) { create(:variant, repair_shopr_id: '4444', product: product) }

    it 'destroys taxons' do
      expect { subject }.to change(Spree::Taxon, :count).by(-1)
      expect { taxon.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'updates sync logs deleted_product_categories' do
      expect { subject }.to change(sync_logs.reload, :deleted_product_categories).from(0).to(1)
    end
  end

  it 'updates sync logs synced_product_categories' do
    taxonomy = create(:taxonomy)
    taxon = create(:taxon, parent: Spree::Taxon.root, taxonomy: taxonomy)
    product = create(:product, taxons: [taxon])
    create(:variant, repair_shopr_id: '1111', product: product)

    expect { subject }.to change(sync_logs.reload, :synced_product_categories).from(0).to(1)
  end

  it 'sets sync logs status to complete when there are no errors' do
    expect { subject }.to change(sync_logs.reload, :status).from('pending').to('complete')
  end

  it 'sets sync logs status to error when there are errors' do
    sync_logs.update!(sync_errors: [{ some: 'errors' }])
    expect { subject }.to change(sync_logs.reload, :status).from('pending').to('error')
  end
end
