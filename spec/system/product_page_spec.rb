# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Product page', type: :system, js: true do
  let!(:store) { create(:smm_store) }
  let!(:product) do
    create(
      :smm_product,
      name: 'Cool product!',
      description: 'This is a cool product.',
      san_francisco_stock: 2,
      bella_vista_stock: 1
    )
  end
  let!(:image) { create(:smm_image, viewable: product.master, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-14a.jpg').open) }
  let!(:image2) { create(:smm_image, viewable: product.master, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-14a.jpg').open) }
  let!(:cross_sell_relation_type) { create(:cross_sell_relation_type) }

  it 'display product informations' do
    visit product_path(product)

    expect(find('h1.product-title')).to have_text('Cool product!')
    expect(find('.product-description')).to have_text('This is a cool product.')
  end

  it 'allows to change add to cart quantity' do
    visit product_path(product)

    quantity_selector = find('.add-to-cart .quantity-selector')
    quantity_input = quantity_selector.find('input#quantity')
    add_quantity = quantity_selector.find("span[data-type='add']")
    remove_quantity = quantity_selector.find("span[data-type='remove']")

    expect(quantity_input.value).to eq('1')
    expect(quantity_selector).to have_selector("span[data-type='remove'].disabled")

    add_quantity.click
    sleep(0.5)
    add_quantity.click

    expect(quantity_input.value).to eq('3')
    expect(quantity_selector).to have_selector("span[data-type='add'].disabled")

    remove_quantity.click
    sleep(0.5)
    remove_quantity.click

    expect(quantity_input.value).to eq('1')
    expect(quantity_selector).to have_selector("span[data-type='remove'].disabled")
  end

  it 'displays product main photo and thumbnails' do
    visit product_path(product)

    expect(find('#product-images #main-image img')['src'])
      .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fit,d_test:products:product-image-placeholder.jpg,w_600/v1/test/products/#{image.attachment.key}")

    expect(find('#product-images #thumbnails .thumbnail.selected img')['src'])
      .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fit,d_test:products:product-image-placeholder.jpg,h_48/v1/test/products/#{image.attachment.key}")

    find('#product-images #thumbnails .thumbnail:last-child').click

    expect(find('#product-images #main-image img')['src'])
      .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fit,d_test:products:product-image-placeholder.jpg,w_600/v1/test/products/#{image2.attachment.key}")

    expect(find('#product-images #thumbnails .thumbnail.selected img')['src'])
      .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fit,d_test:products:product-image-placeholder.jpg,h_48/v1/test/products/#{image2.attachment.key}")
  end

  context 'when product has variants' do
    let(:option_type) { create(:option_type, name: 'color', presentation: 'color', products: [product]) }
    let(:option_type2) { create(:option_type, name: 'model', presentation: 'model', products: [product]) }
    let(:option_type3) { create(:option_type, name: 'capacitye', presentation: 'capacity', products: [product]) }
    let(:option_value) { create(:option_value, option_type: option_type, name: 'Verde', presentation: 'Verde') }
    let(:option_value2) { create(:option_value, option_type: option_type, name: 'Rojo', presentation: 'Rojo') }
    let(:option_value3) { create(:option_value, option_type: option_type2, name: 'iPhone15', presentation: 'iPhone 15') }
    let(:option_value4) { create(:option_value, option_type: option_type3, name: '128gb', presentation: '128gb') }
    let(:option_value5) { create(:option_value, option_type: option_type3, name: '256gn', presentation: '256gb') }
    let!(:variant) { create(:smm_variant, product: product, option_values: [option_value, option_value3, option_value4]) }
    let!(:variant2) { create(:smm_variant, product: product, option_values: [option_value, option_value3, option_value5]) }
    let!(:variant3) { create(:smm_variant, product: product, option_values: [option_value2, option_value3, option_value4]) }
    let!(:price) { create(:price, amount: 12.34, variant: variant) }
    let!(:price2) { create(:price, amount: 333.21, variant: variant2) }
    let!(:price3) { create(:price, amount: 12.34, variant: variant3) }
    let(:calculator) { create(:fixed_amount_sale_price_calculator) }
    let!(:sale_price) { create(:sale_price, enabled: true, value: 10.00, price: price3, calculator: calculator) }
    let!(:image3) { create(:smm_image, viewable: variant, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-15.png').open) }
    let(:stock_item2) { create(:stock_item, variant: variant) }
    let(:stock_item3) { create(:stock_item, variant: variant2) }
    let(:stock_item4) { create(:stock_item, variant: variant3) }

    before do
      stock_item2.set_count_on_hand(1)
      stock_item3.set_count_on_hand(0)
      stock_item4.set_count_on_hand(3)

      visit product_path(product)
    end

    it 'selects cheapest variant by default' do
      expect(page).to have_current_path("/productos/cool-product?variant_id=#{variant3.id}")

      add_to_cart_form = find("#add-to-cart-form form[data-spec='line-items-cart']")

      expect(find("#product-variants #variant-colors .color-badges input[type='radio']#color_option_#{option_value2.id}", visible: false)).to be_checked
      expect(find("#product-variants .variant-options[data-spec='option-type-#{option_type3.id}'] option[value='#{option_value4.id}']")).to be_selected
      expect(add_to_cart_form.find('#product-price .original.crossed')).to have_text('$12.34')
      expect(add_to_cart_form.find('#product-price .discount')).to have_text('$10.00')
      expect(add_to_cart_form.find("input[name='variant_id']", visible: false).value.to_i).to eq(variant3.id)
    end

    it 'displays color information, allows to change it and update variant infos' do
      green_option = find("#product-variants #variant-colors .color-badges label[for='color_option_#{option_value.id}']")
      red_option = find("#product-variants #variant-colors .color-badges label[for='color_option_#{option_value2.id}']")

      expect(green_option.style('background-color')['background-color']).to eq('rgba(152, 225, 100, 1)')
      expect(red_option.style('background-color')['background-color']).to eq('rgba(187, 11, 45, 1)')

      green_option.click
      sleep(0.5)

      expect(find('#product-images #main-image img')['src'])
        .to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fit,d_test:products:product-image-placeholder.jpg,w_600/v1/test/products/#{image3.attachment.key}")
      expect(find("#product-variants #variant-colors .color-badges input[type='radio']#color_option_#{option_value.id}", visible: false)).to be_checked
      expect(find("#add-to-cart-form form[data-spec='line-items-cart'] #product-price")).to have_text('$12.34')
      expect(find("#add-to-cart-form form[data-spec='line-items-cart'] input[name='variant_id']", visible: false).value.to_i).to eq(variant.id)

      add_to_cart_button = find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn")
      expect(add_to_cart_button).not_to be_disabled
      expect(add_to_cart_button).to have_text('COMPRAR')
    end

    it 'displays model information but doesnt allow to change it' do
      model_option = find("#product-variants .variant-options[data-spec='option-type-#{option_type2.id}']")

      expect(model_option).to have_text('iPhone 15')
      expect(model_option).not_to have_selector('select')
    end

    it 'displays capacity information, allows to change it and update variant infos' do
      find("#product-variants #variant-colors .color-badges label[for='color_option_#{option_value.id}']").click

      capacity_option = find("#product-variants .variant-options[data-spec='option-type-#{option_type3.id}'] select")
      capacity_option.click
      capacity_option.find("option[value='#{option_value5.id}']").click

      expect(find("#add-to-cart-form form[data-spec='line-items-cart'] #product-price")).to have_text('$333.21')
      expect(find("#add-to-cart-form form[data-spec='line-items-cart'] input[name='variant_id']", visible: false).value.to_i).to eq(variant2.id)

      add_to_cart_button = find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn")
      expect(add_to_cart_button).to be_disabled
      expect(add_to_cart_button).to have_text('AGOTADO')
    end

    it 'disable buy button if variant doesnt exist' do
      capacity_option = find("#product-variants .variant-options[data-spec='option-type-#{option_type3.id}'] select")
      capacity_option.click
      capacity_option.find("option[value='#{option_value5.id}']").click
      sleep(0.5)

      add_to_cart_button = find('#add-to-cart-form button')
      expect(add_to_cart_button).to be_disabled
      expect(add_to_cart_button).to have_text('PRODUCTO NO DISPONIBLE')
      expect(find("#add-to-cart-form [data-spec='no-variant-explanation']")).to have_text('No exist producto con las opciones seleccionadas. Por favor elija otras opciones.')
    end

    it 'allows to add selected variant to cart' do
      expect(page).not_to have_selector("[data-spec='add-to-cart-modal']")

      add_to_cart_button = find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn")
      add_to_cart_button.click
      sleep(1)

      expect(find("[data-spec='add-to-cart-modal']").style('display')['display']).to eq('block')
      expect(find("[data-spec='add-to-cart-modal'] .modal-body")).to have_text('Cool product! - 128gb, Rojo añadido a su carrito')

      find("[data-spec='add-to-cart-modal'] .modal-footer [data-spec='close-modal']").click
      sleep(1)

      expect(find('header nav #navbar-cart-quantity')).to have_text('1')
      expect(page).not_to have_selector("[data-spec='add-to-cart-modal']")

      find(".add-to-cart .quantity-selector span[data-type='add']").click
      add_to_cart_button.click
      sleep(1)

      find("[data-spec='add-to-cart-modal'] .modal-footer [data-spec='go-to-cart']").click
      expect(page).to have_current_path('/carrito')

      order = Spree::Order.last
      line_item = order.line_items.last
      expect(order.state).to eq('cart')
      expect(order.line_items.count).to eq(1)
      expect(line_item.variant).to eq(variant3)
      expect(line_item.quantity).to eq(3)
      expect(line_item.price).to eq(10.00)
    end
  end

  context 'when product doesnt have any variant' do
    let!(:option_type) { create(:option_type, name: 'model', products: [product]) }
    let!(:option_value) { create(:option_value, option_type: option_type, presentation: 'iPhone 15') }
    let!(:price) { create(:price, amount: 12.34, variant: product.master) }

    it 'displays master options text' do
      product.master.update!(option_values: [option_value])

      visit product_path(product)

      expect(find('.master-description')).to have_text('Modelo: Iphone 15')
      expect(page).not_to have_selector('#product-variants')
    end

    it 'allows to add product master to cart' do
      visit product_path(product)

      expect(page).not_to have_selector("[data-spec='add-to-cart-modal']")

      add_to_cart_button = find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn")
      add_to_cart_button.click
      sleep(1)

      expect(find("[data-spec='add-to-cart-modal']").style('display')['display']).to eq('block')
      expect(find("[data-spec='add-to-cart-modal'] .modal-body")).to have_text('Cool product! añadido a su carrito')

      find("[data-spec='add-to-cart-modal'] .modal-footer [data-spec='close-modal']").click
      sleep(1)

      expect(find('header nav #navbar-cart-quantity')).to have_text('1')
      expect(page).not_to have_selector("[data-spec='add-to-cart-modal']")

      find(".add-to-cart .quantity-selector span[data-type='add']").click
      add_to_cart_button.click
      sleep(1)

      find("[data-spec='add-to-cart-modal'] .modal-footer [data-spec='go-to-cart']").click
      expect(page).to have_current_path('/carrito')

      order = Spree::Order.last
      line_item = order.line_items.last
      expect(order.state).to eq('cart')
      expect(order.line_items.count).to eq(1)
      expect(line_item.variant).to eq(product.master)
      expect(line_item.quantity).to eq(3)
      expect(line_item.price).to eq(12.34)
    end
  end
end
