# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepairShoprApi::V1::SyncProduct, type: :service do
  subject { described_class.call(sync_logs: sync_logs, attributes: attributes.dup) }

  let!(:sync_logs) { create(:repair_shopr_products_sync_log) }
  let!(:default_shipping_category) { create(:shipping_category, name: 'Default') }
  let!(:san_francisco_stock_location) { create(:smm_stock_location, :san_francisco) }
  let!(:bella_vista_stock_location) { create(:smm_stock_location, :bella_vista) }
  let!(:categories_taxonomy) { create(:taxonomy, name: 'Categories') }
  let(:notes) { '' }
  let(:product_category) { 'ecom;iPhones' }
  let(:photos) { [] }
  let(:attributes) do
    {
      'id' => 1234,
      'price_cost' => 800.0,
      'price_retail' => 1016.45,
      'condition' => '',
      'description' => 'Cool product',
      'maintain_stock' => true,
      'name' => 'iPhone 14 -  Nuevo - 128GB- RED- eSIM ',
      'quantity' => 0,
      'warranty' => nil,
      'sort_order' => nil,
      'reorder_at' => nil,
      'disabled' => false,
      'taxable' => true,
      'product_category' => product_category,
      'category_path' => product_category,
      'upc_code' => '1234ABCD',
      'discount_percent' => nil,
      'warranty_template_id' => 27_530,
      'qb_item_id' => nil,
      'desired_stock_level' => nil,
      'price_wholesale' => 0.0,
      'notes' => notes,
      'tax_rate_id' => nil,
      'physical_location' => '',
      'serialized' => false,
      'vendor_ids' => [],
      'long_description' => nil,
      'location_quantities' => [
        {
          'id' => 11_691_524,
          'product_id' => 18_490_087,
          'location_id' => 1927,
          'quantity' => 3,
          'tax_rate_id' => nil,
          'created_at' => '2023-06-01T12:27:36.645-05:00',
          'updated_at' => '2023-06-01T12:27:36.645-05:00',
          'reorder_at' => nil,
          'desired_stock_level' => nil,
          'price_cost_cents' => nil,
          'price_retail_cents' => nil
        },
        {
          'id' => 11_691_525,
          'product_id' => 18_490_087,
          'location_id' => 1928,
          'quantity' => 10,
          'tax_rate_id' => nil,
          'created_at' => '2023-06-01T12:27:36.651-05:00',
          'updated_at' => '2023-08-17T10:23:32.299-05:00',
          'reorder_at' => nil,
          'desired_stock_level' => nil,
          'price_cost_cents' => nil,
          'price_retail_cents' => nil
        }
      ],
      'photos' => photos
    }
  end
  let(:price_before_tax) { attributes['price_retail'] - ((attributes['price_retail'] / 1.07) * 0.07) }

  it 'logs infos' do
    expect(Rails.logger).to receive(:info).with("Start to sync product with RepairShopr ID: #{attributes['id']}")
    expect(Rails.logger).to receive(:info).with("Product with RepairShopr ID: #{attributes['id']} synced")

    subject
  end

  it 'updates sync logs synced products count' do
    expect { subject }.to change(sync_logs, :synced_products).from(0).to(1)
  end

  it 'returns created/updated variant' do
    variant = subject
    expect(variant).to be_a(Spree::Variant)
    expect(variant.repair_shopr_id).to eq(attributes['id'])
  end

  context 'when product has variants' do
    # Those are messy notes on purpose (with blanks line, spaces, uppercase etc...) to check that it's correctly cleaned up
    let(:notes) { "  color: Red \r\ncapacity = 128GB\r\n MODEL: iPhone 14\r\n   \r\nparent_product   : iPhone 14\nhighlight: yes  " }

    it 'creates product and variant with the correct attributes' do
      expect { subject }.to change(Spree::Product, :count).by(1).and change(Spree::Variant, :count).by(2)
      expect(sync_logs.reload.sync_errors).to be_empty

      product = Spree::Product.find_by(name: 'iPhone 14')
      expect(product.available_on).to eq(Date.today)
      expect(product.shipping_category).to eq(default_shipping_category)
      expect(product.description).to eq(attributes['description'])
      expect(product.meta_description).to eq("iPhone 14 - #{attributes['description']}")
      expect(product.highlight).to be true
      expect(product.option_types.map(&:name)).to match_array(%w[color capacity model])

      variant = product.variants.find_by(repair_shopr_id: attributes['id'])
      expect(variant.repair_shopr_name).to eq(attributes['name'].strip)
      expect(variant.is_master).to be false
      expect(variant.sku).to eq(attributes['upc_code'])
      expect(variant.cost_price).to eq(attributes['price_cost'])
      expect(variant.option_values.map(&:name)).to match_array(['red', '128gb', 'iPhone 14'])
      expect(variant.condition).to eq('original')
      expect(variant.price).to eq(price_before_tax.round(2))
    end

    context 'when product and variant already exists' do
      let!(:product) { create(:smm_product, available_on: Date.yesterday, name: 'iPhone 14') }
      let!(:variant) { create(:variant, repair_shopr_id: attributes['id'], product: product) }

      it 'updates existing product and variant' do
        expect { subject }.to not_change(Spree::Product, :count).and not_change(Spree::Variant, :count)
        expect(sync_logs.reload.sync_errors).to be_empty

        expect(product.reload.available_on).to eq(Date.yesterday)
        expect(variant.reload.price).to eq(price_before_tax.round(2))
      end
    end

    context 'when option types and option values dont exist' do
      it 'creates the correct option types and option values' do
        expect { subject }.to change(Spree::OptionType, :count).by(3).and change(Spree::OptionValue, :count).by(3)
        expect(sync_logs.reload.sync_errors).to be_empty

        color_type = Spree::OptionType.find_by(name: 'color')
        expect(color_type.presentation).to eq('color')
        expect(color_type.position).to eq(1)
        expect(color_type.option_values.first.name).to eq('red')
        expect(color_type.option_values.first.presentation).to eq('red')

        capacity_type = Spree::OptionType.find_by(name: 'capacity')
        expect(capacity_type.presentation).to eq('capacity')
        expect(capacity_type.option_values.first.name).to eq('128gb')
        expect(capacity_type.option_values.first.presentation).to eq('128gb')

        model_type = Spree::OptionType.find_by(name: 'model')
        expect(model_type.presentation).to eq('model')
        expect(model_type.option_values.first.name).to eq('iPhone 14')
        expect(model_type.option_values.first.presentation).to eq('iPhone 14')
      end
    end

    context 'when option types and option values already exist' do
      let(:option_type) { create(:option_type, name: 'color', presentation: 'color') }
      let!(:option_value) { create(:option_value, name: 'red', presentation: 'red', option_type: option_type) }

      it 'uses already existing option types and option values' do
        expect { subject }.to change(Spree::OptionType, :count).by(2).and change(Spree::OptionValue, :count).by(2)
        expect(sync_logs.reload.sync_errors).to be_empty
      end
    end
  end

  context 'when product doesnt have variant' do
    it 'creates product and master with the correct attributes' do
      expect { subject }.to change(Spree::Product, :count).by(1).and change(Spree::Variant, :count).by(1)
      expect(sync_logs.reload.sync_errors).to be_empty

      product = Spree::Product.find_by(name: 'iPhone 14 -  Nuevo - 128GB- RED- eSIM')
      expect(product.available_on).to eq(Date.today)
      expect(product.shipping_category).to eq(default_shipping_category)
      expect(product.description).to eq(attributes['description'])
      expect(product.meta_description).to eq("#{attributes['name'].strip} - #{attributes['description']}")
      expect(product.highlight).to be false
      expect(product.option_types).to eq([])

      variant = product.master
      expect(variant.repair_shopr_id).to eq(attributes['id'])
      expect(variant.repair_shopr_name).to eq(attributes['name'].strip)
      expect(variant.is_master).to be true
      expect(variant.sku).to eq(attributes['upc_code'])
      expect(variant.cost_price).to eq(attributes['price_cost'])
      expect(variant.option_values).to eq([])
      expect(variant.condition).to eq('original')
      expect(variant.price).to eq(price_before_tax.round(2))
    end

    context 'when product already exists' do
      let!(:product) { create(:smm_product, name: attributes['name'].strip, available_on: Date.yesterday, master_repair_shopr_id: attributes['id']) }

      it 'updates existing product' do
        expect { subject }.to not_change(Spree::Product, :count).and not_change(Spree::Variant, :count)
        expect(sync_logs.reload.sync_errors).to be_empty

        expect(product.reload.available_on).to eq(Date.yesterday)
        expect(product.master.reload.price).to eq(price_before_tax.round(2))
      end
    end

    it 'doesnt create option types and option values' do
      expect { subject }.to not_change(Spree::OptionType, :count).and not_change(Spree::OptionValue, :count)
    end
  end

  context 'stock updates' do
    context 'when stock increases' do
      it 'adds stocks to product at every stock locations' do
        subject
        expect(sync_logs.reload.sync_errors).to be_empty

        product = Spree::Variant.find_by(repair_shopr_id: attributes['id']).product

        expect(product.stock_items.find_by(stock_location: san_francisco_stock_location).count_on_hand).to eq(3)
        expect(product.stock_items.find_by(stock_location: bella_vista_stock_location).count_on_hand).to eq(10)
      end
    end

    context 'when stock decreases' do
      let!(:product) do
        create(
          :smm_product,
          name: 'iPhone 14',
          master_repair_shopr_id: attributes['id'],
          san_francisco_stock: 5,
          bella_vista_stock: 15
        )
      end

      it 'removes stocks to product at every stock locations' do
        subject
        expect(sync_logs.reload.sync_errors).to be_empty

        expect(product.stock_items.find_by(stock_location: san_francisco_stock_location).count_on_hand).to eq(3)
        expect(product.stock_items.find_by(stock_location: bella_vista_stock_location).count_on_hand).to eq(10)
      end
    end

    context 'when stock doesnt change' do
      let!(:product) do
        create(
          :smm_product,
          name: 'iPhone 14',
          master_repair_shopr_id: attributes['id'],
          san_francisco_stock: 3,
          bella_vista_stock: 10
        )
      end

      it 'doesnt change product stocks' do
        subject
        expect(sync_logs.reload.sync_errors).to be_empty

        expect(product.stock_items.find_by(stock_location: san_francisco_stock_location).count_on_hand).to eq(3)
        expect(product.stock_items.find_by(stock_location: bella_vista_stock_location).count_on_hand).to eq(10)
      end
    end
  end

  context 'product category updates' do
    let(:product_category) { 'ecom;Smart Phones;iPhones;iPhones 13' }

    it 'updates product classification' do
      expect { subject }.to change(Spree::Classification, :count).by(1)

      product = Spree::Variant.find_by(repair_shopr_id: attributes['id']).product
      expect(product.classifications.size).to eq(1)
      expect(product.classifications.last.taxon.name).to eq('iPhones 13')
    end

    it 'creates taxons with the correct taxonomy and hierarchy if it doesnt exists' do
      expect { subject }.to change(Spree::Taxon, :count).by(3)

      taxon1 = Spree::Taxon.find_by!(name: 'Smart Phones')
      taxon2 = Spree::Taxon.find_by!(name: 'iPhones')
      taxon3 = Spree::Taxon.find_by!(name: 'iPhones 13')

      expect(taxon3.taxonomy).to eq(categories_taxonomy)
      expect(taxon3.parent).to eq(taxon2)
      expect(taxon2.taxonomy).to eq(categories_taxonomy)
      expect(taxon2.parent).to eq(taxon1)
      expect(taxon1.taxonomy).to eq(categories_taxonomy)
      expect(taxon1.parent).to eq(categories_taxonomy.taxons.find_by(parent: nil))
    end

    it 'uses taxon if it already exists' do
      create(:taxon, name: 'Smart Phones', parent: categories_taxonomy.taxons.root, taxonomy: categories_taxonomy)
      expect { subject }.to change(Spree::Taxon, :count).by(2)
      expect(sync_logs.reload.sync_errors).to be_empty
    end

    context 'when product category is the root category' do
      let(:product_category) { 'ecom' }

      it 'sets products under root taxon' do
        expect { subject }.not_to change(Spree::Taxon, :count)
        expect(sync_logs.reload.sync_errors).to be_empty

        product = Spree::Variant.find_by(repair_shopr_id: attributes['id']).product
        expect(product.taxons).to eq([categories_taxonomy.taxons.find_by(parent: nil)])
      end
    end
  end

  context 'variant reassignment' do
    context 'when adding parent_product to notes' do
      let(:notes) { "color: Red \r\ncapacity: 128GB\r\nmodel: iPhone 14\r\nparent_product: iPhone 14\r\nhighlight: yes" }
      let!(:other_product) { create(:smm_product, name: 'other iPhone', master_repair_shopr_id: attributes['id']) }

      context 'when the corresponding parent product doesnt exist' do
        it 'reassigns variant to a new product and destroy the old one' do
          variant = other_product.master

          expect { subject }.to not_change(Spree::Product, :count).and change(Spree::Variant, :count).by(1)
          expect(sync_logs.reload.sync_errors).to be_empty

          expect { other_product.reload }.to raise_error(ActiveRecord::RecordNotFound)

          new_product = Spree::Product.find_by(name: 'iPhone 14')
          expect(new_product).not_to eq(other_product)
          expect(new_product.variants).to eq([variant])
          expect(variant.reload.price).to eq(price_before_tax.round(2))
        end
      end

      context 'when the corresponding parent product exists' do
        let!(:product) { create(:smm_product, name: 'iPhone 14') }

        it 'reassigns variant to this existing product and destroy the old one' do
          variant = other_product.master

          expect { subject }.to change(Spree::Product, :count).by(-1).and not_change(Spree::Variant, :count)
          expect(sync_logs.reload.sync_errors).to be_empty

          expect { other_product.reload }.to raise_error(ActiveRecord::RecordNotFound)

          expect(product).not_to eq(other_product)
          expect(product.variants).to eq([variant])
          expect(variant.reload.price).to eq(price_before_tax.round(2))
        end
      end
    end

    context 'when removing parent_product to notes' do
      let(:product) { create(:smm_product, name: 'other iPhone') }
      let!(:variant) { create(:variant, repair_shopr_id: attributes['id'], product: product) }

      it 'sets variant has the product master' do
        expect { subject }.to not_change(Spree::Product, :count).and change(Spree::Variant, :count).by(-1)
        expect(sync_logs.reload.sync_errors).to be_empty

        expect(product.reload.deleted_at).to be nil
        expect(product.variants).to eq([])
        expect(product.master).to eq(variant)
        expect(variant.reload.price).to eq(price_before_tax.round(2))
      end

      # This shouldn't really happens has the remaining variant will take precedent over the new master...
      # Also the master price can't really be set because of PriceDecorator#equalize_master_price_for_products_with_variants
      # Anyway, we expect that if parent_product is removed it would be removed from all RS products and we won't have remaining variants
      context 'when the parent product have other variants' do
        let!(:other_variant) { create(:variant, product: product) }

        it 'sets variant has the product master' do
          expect { subject }.to not_change(Spree::Product, :count).and change(Spree::Variant, :count).by(-1)
          expect(sync_logs.reload.sync_errors).to be_empty

          expect(product.reload.deleted_at).to be nil
          expect(product.variants).to eq([other_variant])
          expect(product.master).to eq(variant)
        end
      end
    end

    context 'when changing parent_product in notes' do
      let(:notes) { "color: Red \r\ncapacity: 128GB\r\nmodel: iPhone 14\r\nparent_product: iPhone 14\r\nhighlight: yes" }
      let(:old_product) { create(:smm_product, name: 'other iPhone') }
      let!(:variant) { create(:variant, repair_shopr_id: attributes['id'], product: old_product) }
      let!(:other_variant) { create(:variant, product: old_product) }

      it 'reassings variant to a new parent product' do
        expect { subject }.to change(Spree::Product, :count).by(1).and change(Spree::Variant, :count).by(1)
        expect(sync_logs.reload.sync_errors).to be_empty

        expect(old_product.reload.deleted_at).to be nil
        expect(old_product.variants).to eq([other_variant])

        new_product = Spree::Product.find_by(name: 'iPhone 14')
        expect(new_product).not_to eq(old_product)
        expect(new_product.variants).to eq([variant])
        expect(variant.reload.price).to eq(price_before_tax.round(2))
      end

      context 'when new parent already exists' do
        let!(:existing_product) { create(:smm_product, name: 'iPhone 14') }

        it 'reassigns variant to this existing new parent product' do
          expect { subject }.to not_change(Spree::Product, :count).and not_change(Spree::Variant, :count)
          expect(sync_logs.reload.sync_errors).to be_empty

          expect(old_product.reload.deleted_at).to be nil
          expect(old_product.variants).to eq([other_variant])

          expect(existing_product).not_to eq(old_product)
          expect(existing_product.variants).to eq([variant])
          expect(variant.reload.price).to eq(price_before_tax.round(2))
        end
      end

      context 'when old parent product doesnt have other variant' do
        it 'reassings variant to a new parent product and destroy old parent product' do
          other_variant.destroy!
          expect { subject }.to not_change(Spree::Product, :count).and not_change(Spree::Variant, :count)
          expect(sync_logs.reload.sync_errors).to be_empty

          expect { old_product.reload }.to raise_error(ActiveRecord::RecordNotFound)

          new_product = Spree::Product.find_by(name: 'iPhone 14')
          expect(new_product).not_to eq(old_product)
          expect(new_product.variants).to eq([variant])
          expect(variant.reload.price).to eq(price_before_tax.round(2))
        end
      end
    end
  end

  context 'variant images' do
    let(:photos) do
      [
        {
          'id' => 321_855,
          'created_at' => '2023-06-01T12:30:05.376-05:00',
          'updated_at' => '2023-06-01T12:30:05.376-05:00',
          'photo_url' => "#{Rails.root}/spec/fixtures/product_images/iphone-14a.jpg",
          'thumbnail_url' => "#{Rails.root}/spec/fixtures/product_images/thumbnail-iphone-14a.jpg"
        },
        {
          'id' => 321_856,
          'created_at' => '2023-06-01T12:30:09.376-05:00',
          'updated_at' => '2023-06-01T12:30:09.376-05:00',
          'photo_url' => "#{Rails.root}/spec/fixtures/product_images/iphone-14b.jpg",
          'thumbnail_url' => "#{Rails.root}/spec/fixtures/product_images/thumbnail-iphone-14b.jpg"
        }
      ]
    end

    before do
      # Stub URI::HTTPS so that #open method works with a local URL
      photos.each do |photo|
        uri_instance_double = instance_double(URI::HTTPS)
        allow(URI).to receive(:parse).with(photo['photo_url']).and_return(uri_instance_double)
        allow(uri_instance_double).to receive(:open).and_return(File.open(photo['photo_url']))
      end
    end

    after do
      # Remove attached files
      FileUtils.rm_rf(Rails.configuration.active_storage.service_configurations['cloudinary_products']['root'])
    end

    it 'create variant images' do
      expect { subject }.to change(Spree::Image, :count).by(2)
      expect(sync_logs.reload.sync_errors).to be_empty

      variant = Spree::Variant.find_by(repair_shopr_id: attributes['id'])

      image1 = variant.images.find_by(repair_shopr_id: 321_855)
      expect(image1.alt).to eq(variant.name)
      expect(image1.attachment.attached?).to be true
      expect(image1.attachment.filename).to eq("#{variant.product.slug}-#{variant.repair_shopr_id}")

      image2 = variant.images.find_by(repair_shopr_id: 321_856)
      expect(image2.alt).to eq(variant.name)
      expect(image2.attachment.attached?).to be true
      expect(image2.attachment.filename).to eq("#{variant.product.slug}-#{variant.repair_shopr_id}")
    end

    it 'doesnt create image if it already exists' do
      variant = create(:variant, repair_shopr_id: attributes['id'])
      image = Spree::Image.new(
        viewable_type: 'Spree::Variant',
        viewable_id: variant.id,
        repair_shopr_id: photos.first['id'],
        alt: variant.name
      )
      image.attachment.attach(io: URI.parse(photos.first['photo_url']).open, filename: 'filename')
      image.save!

      expect { subject }.to change(Spree::Image, :count).by(1)
      expect(sync_logs.reload.sync_errors).to be_empty
    end

    it 'updates sync_logs synced images count' do
      expect { subject }.to change(sync_logs.reload, :synced_product_images).from(0).to(2)
    end

    it 'destroys old variant images' do
      variant = create(:variant, repair_shopr_id: attributes['id'])
      old_image = Spree::Image.new(
        viewable_type: 'Spree::Variant',
        viewable_id: variant.id,
        repair_shopr_id: 'ABCD',
        alt: variant.name
      )
      old_image.attachment.attach(io: URI.parse(photos.first['photo_url']).open, filename: 'filename')
      old_image.save!

      expect { subject }.to change(Spree::Image, :count).by(1)
      expect { old_image.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(sync_logs.reload.deleted_product_images).to eq(1)
    end

    context 'when variant image cant be created' do
      before do
        allow_any_instance_of(Spree::Image).to receive(:save!).and_raise('Booom')
      end

      it 'rescues error and add it to sync logs' do
        expect { subject }.not_to raise_error
        expect(sync_logs.reload.sync_errors).to match_array(
          [
            { 'product_image_repair_shopr_id' => photos.first['id'], 'error' => 'Booom' },
            { 'product_image_repair_shopr_id' => photos.last['id'], 'error' => 'Booom' }
          ]
        )
      end
    end
  end

  context 'when two different products have the same name' do
    let!(:wrong_product) { create(:smm_product, name: 'iPhone 14 -  Nuevo - 128GB- RED- eSIM', description: 'old description') }
    let!(:product) do
      create(
        :smm_product,
        name: 'iPhone 14 -  Nuevo - 128GB- RED- eSIM',
        description: 'old description',
        master_repair_shopr_id: attributes['id']
      )
    end

    it 'updates the correct product' do
      expect { subject }.to not_change(Spree::Product, :count).and not_change(Spree::Variant, :count)
      expect(sync_logs.reload.sync_errors).to be_empty

      expect(product.reload.description).to eq(attributes['description'])
      expect(wrong_product.reload.description).to eq('old description')
    end
  end

  context 'when any error is raised' do
    let(:sync_logs_errors) { [{ 'product_repair_shopr_id' => attributes['id'], 'error' => 'Booom' }] }

    before do
      allow_any_instance_of(Spree::Variant).to receive(:save!).and_raise('Booom')
      allow(Sentry).to receive(:capture_message)
    end

    it 'rescues error and add it to sync logs' do
      expect { subject }.not_to raise_error
      expect(sync_logs.sync_errors).to eq(sync_logs_errors)
    end

    it 'sends message to Sentry' do
      expect(SendMessageToSentry).to receive(:send).with(described_class.name, { sync_logs_errors: sync_logs_errors })
      subject
    end
  end
end
