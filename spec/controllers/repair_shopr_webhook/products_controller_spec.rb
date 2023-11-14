# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepairShoprWebhook::ProductsController, type: :request do
  describe '#product_updated' do
    subject do
      post '/repair_shopr_webhook/product_updated', params: {
        link: link,
        attributes: attributes
      }
    end

    context 'when request is from the correct RepairShopr domain' do
      let(:link) { 'https://rs_test_domain.repairshopr.com/products/1234' }

      context 'when product is in the RepairShopr ecom root category' do
        context 'when product is disabled' do
          let(:attributes) do
            {
              id: '1234',
              product_category: 'ecom;iPhones',
              disabled: 'true'
            }
          end

          it 'doesnt get product attributes and doesnt sync it' do
            expect(RepairShoprApi::V1::Base).not_to receive(:get_product)
            expect(RepairShoprApi::V1::SyncProduct).not_to receive(:call)

            subject
          end

          context 'when variant already exists' do
            let(:product) { create(:product) }
            let!(:variant) { create(:variant, repair_shopr_id: '1234', product: product) }

            it 'destroys it' do
              variant2 = create(:variant, repair_shopr_id: '5678', product: product)

              subject

              expect(variant.reload.deleted_at).not_to be nil
              expect(variant2.reload.deleted_at).to be nil
              expect(product.reload.deleted_at).to be nil
            end

            it 'destroys product if it has no other variants' do
              subject

              expect(variant.reload.deleted_at).not_to be nil
              expect(product.reload.deleted_at).not_to be nil
            end
          end
        end

        context 'when product is not disabled' do
          let(:attributes) do
            {
              id: '1234',
              product_category: 'ecom;iPhones'
            }
          end

          before do
            allow(RepairShoprApi::V1::Base).to receive(:get_product).with('1234').and_return(:fake_product)
            allow(RepairShoprApi::V1::SyncProduct).to receive(:call)
          end

          it 'gets product attributes and sync it' do
            expect(RepairShoprApi::V1::Base).to receive(:get_product).with('1234')
            expect(RepairShoprApi::V1::SyncProduct).to receive(:call).with(sync_logs: be_a(RepairShoprProductsSyncLog), attributes: :fake_product)

            subject
          end

          it 'updates sync logs status' do
            subject

            expect(RepairShoprProductsSyncLog.last.status).to eq('complete')
          end
        end
      end

      context 'when product is not in the RepairShopr ecom root category' do
        context 'when product is disabled' do
          let(:attributes) do
            {
              id: '1234',
              product_category: 'phones;iPhones',
              disabled: 'true'
            }
          end

          it 'doesnt get product attributes and doesnt sync it' do
            expect(RepairShoprApi::V1::Base).not_to receive(:get_product)
            expect(RepairShoprApi::V1::SyncProduct).not_to receive(:call)

            subject
          end

          context 'when variant already exists' do
            let(:product) { create(:product) }
            let!(:variant) { create(:variant, repair_shopr_id: '1234', product: product) }

            it 'destroys it' do
              variant2 = create(:variant, repair_shopr_id: '5678', product: product)

              subject

              expect(variant.reload.deleted_at).not_to be nil
              expect(variant2.reload.deleted_at).to be nil
              expect(product.reload.deleted_at).to be nil
            end

            it 'destroys product if it has no other variants' do
              subject

              expect(variant.reload.deleted_at).not_to be nil
              expect(product.reload.deleted_at).not_to be nil
            end
          end
        end

        context 'when product is not disabled' do
          let(:attributes) do
            {
              id: '1234',
              product_category: 'phones;iPhones',
            }
          end

          it 'doesnt get product attributes and doesnt sync it' do
            expect(RepairShoprApi::V1::Base).not_to receive(:get_product)
            expect(RepairShoprApi::V1::SyncProduct).not_to receive(:call)

            subject
          end

          context 'when variant already exists' do
            let(:product) { create(:product) }
            let!(:variant) { create(:variant, repair_shopr_id: '1234', product: product) }

            it 'destroys it' do
              variant2 = create(:variant, repair_shopr_id: '5678', product: product)

              subject

              expect(variant.reload.deleted_at).not_to be nil
              expect(variant2.reload.deleted_at).to be nil
              expect(product.reload.deleted_at).to be nil
            end

            it 'destroys product if it has no other variants' do
              subject

              expect(variant.reload.deleted_at).not_to be nil
              expect(product.reload.deleted_at).not_to be nil
            end
          end
        end
      end
    end

    context 'when request is not from the correct RepairShopr domain' do
      let(:link) { 'https://other_domain.repairshopr.com/products/1234' }
      let(:attributes) do
        {
          id: '1234',
          product_category: 'ecom;iPhones'
        }
      end

      it 'doesnt get product attributes and doesnt sync it' do
        expect(RepairShoprApi::V1::Base).not_to receive(:get_product)
        expect(RepairShoprApi::V1::SyncProduct).not_to receive(:call)

        subject
      end
    end

    it 'returns head ok' do
      post '/repair_shopr_webhook/product_updated', params: {
        link: 'https://rs_test_domain.repairshopr.com/products/1234',
        attributes: { some: :attributes }
      }
      expect(response.status).to eq(200)
    end
  end
end
