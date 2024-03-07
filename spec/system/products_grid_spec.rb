# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Products grid', type: :system do
  let!(:taxon) { create(:taxon, name: 'iphone') }
  let(:option_type) { create(:option_type, name: 'color') }
  let(:option_type2) { create(:option_type, name: 'model') }
  let(:option_type3) { create(:option_type, name: 'capacity') }
  let(:option_value) { create(:option_value, option_type: option_type, name: 'Verde') }
  let(:option_value2) { create(:option_value, option_type: option_type, name: 'Rojo') }
  let(:option_value3) { create(:option_value, option_type: option_type, name: 'Azul') }
  let(:option_value4) { create(:option_value, option_type: option_type, name: 'Negro') }
  let(:option_value5) { create(:option_value, option_type: option_type2, name: 'iPhone 11') }
  let(:option_value6) { create(:option_value, option_type: option_type2, name: 'iPhone 12') }
  let(:option_value7) { create(:option_value, option_type: option_type2, name: 'iPhone 13') }
  let(:option_value8) { create(:option_value, option_type: option_type2, name: 'iPhone 14') }
  let(:option_value9) { create(:option_value, option_type: option_type3, name: '64gb') }
  let(:option_value10) { create(:option_value, option_type: option_type3, name: '128gb') }
  let(:option_value11) { create(:option_value, option_type: option_type3, name: '256gb') }
  let(:option_value12) { create(:option_value, option_type: option_type3, name: '512gb') }
  let(:product) { create(:smm_product, name: 'First cool product', taxons: [taxon]) }
  let(:product2) { create(:smm_product, name: 'Second cool product', taxons: [taxon]) }
  let(:product3) { create(:smm_product, name: 'Third cool product', taxons: [taxon]) }
  let(:variant) { create(:variant, product: product, option_values: [option_value, option_value5, option_value9]) }
  let(:variant2) { create(:variant, product: product, option_values: [option_value2, option_value6, option_value10]) }
  let(:variant3) { create(:variant, product: product2, option_values: [option_value3, option_value7, option_value11]) }
  let(:variant4) { create(:variant, product: product2, option_values: [option_value4, option_value8, option_value12]) }
  let!(:price) { create(:price, amount: 12.34, variant: variant) }
  let!(:price2) { create(:price, amount: 22.21, variant: variant2) }
  let!(:price3) { create(:price, amount: 666.32, variant: variant3) }
  let!(:price4) { create(:price, amount: 555.11, variant: variant4) }
  let!(:price5) { create(:price, amount: 100, variant: product3.master) }
  let(:calculator) { create(:fixed_amount_sale_price_calculator) }
  let!(:sale_price2) { create(:sale_price, enabled: true, value: 444.22, price: price3, calculator: calculator) }
  let!(:image) { create(:smm_image, viewable: variant, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-14a.jpg').open) }
  let!(:image2) { create(:smm_image, viewable: variant3, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-14a.jpg').open) }
  let!(:image3) { create(:smm_image, viewable: product3.master, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-14a.jpg').open) }
  let!(:cross_sell_relation_type) { create(:cross_sell_relation_type) }

  it 'displays products with their name price and image', js: true do
    visit nested_taxons_path(taxon)

    products_grid = find('#products #products-grid')

    expect(products_grid).to have_selector("[data-spec='product']", count: 3)

    first_product = products_grid.find("#product_#{product.id}")
    expect(first_product.find('.product-image img')['src'])
      .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fill,d_test:products:product-image-placeholder.jpg,w_540/v1/test/products/#{image.attachment.key}")
    expect(first_product.find('.product-name')).to have_text('First cool product')
    expect(first_product.find('.prices')).to have_text('$12.34')

    second_product = products_grid.find("#product_#{product2.id}")
    expect(second_product.find('.product-image img')['src'])
      .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fill,d_test:products:product-image-placeholder.jpg,w_540/v1/test/products/#{image2.attachment.key}")
    expect(second_product.find('.product-name')).to have_text('Second cool product')
    expect(second_product.find('.prices')).to have_text("$444.22\n$666.32")

    third_product = products_grid.find("#product_#{product3.id}")
    expect(third_product.find('.product-image img')['src'])
      .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fill,d_test:products:product-image-placeholder.jpg,w_540/v1/test/products/#{image3.attachment.key}")
    expect(third_product.find('.product-name')).to have_text('Third cool product')
    expect(third_product.find('.prices')).to have_text('$100.00')

    second_product.click

    expect(page).to have_current_path("/productos/second-cool-product?variant_id=#{variant3.id}")
  end
end
