# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Product page', type: :system, js: true, debug: true do
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
  let!(:price) { create(:price, amount: 12.34, variant: product.master) }
  let!(:image) { create(:smm_image, viewable: product.master, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-14a.jpg').open) }
  let!(:cross_sell_relation_type) { create(:cross_sell_relation_type) }
  let!(:panama_country) { create(:country, name: 'Panama', iso_name: 'PANAMA', iso: 'PA', iso3: 'PAN') }
  let!(:panama_state) { create(:state, name: 'Panamá', country: panama_country) }
  let!(:bella_vista_district) { create(:district, name: 'Bella Vista', latitude: 8.983972, longitude: -79.526022, state: panama_state) }
  let!(:san_francisco_district) { create(:district, name: 'San Francisco', latitude: 8.992609, longitude: -79.507848, state: panama_state) }
  let!(:panama_zone1) { create(:zone, name: 'Panama Zone 1') }
  let!(:zone_member) { create(:zone_member, zoneable: bella_vista_district, zone: panama_zone1) }
  let!(:shipping_method) { create(:shipping_method, name: 'Panama Zone 1', service_level: 'delivery', zones: [panama_zone1]) }

  before do
    visit product_path(product)
    find(".add-to-cart .quantity-selector span[data-type='add']").click
    find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn").click
    find("[data-spec='add-to-cart-modal'] .modal-footer [data-spec='go-to-cart']").click
    find("button[name='checkout'][type='submit'].checkout-button").click
  end

  context 'when user is not logged in' do
    context 'checkout without registration' do
      before do
        find('#checkout_form_registration input#order_email').set('cool_email@gmail.com')
        find("#checkout_form_registration input[type='submit']").click
      end

      context 'address step' do
        it 'displays breadcrumb at address step' do
          expect(find('.progress-steps .current')).to have_text('DIRECCIÓN')
        end

        it 'displays order summary' do
          expect(find("#checkout-summary [data-spec='checkout-summary-products']")).to have_text("2 Productos\n$24.68")
          expect(find('#checkout-summary #summary-order-total')).to have_text('$24.68')
        end

        it 'displays address form with email and city prefilled' do
          address_form = find('form#checkout_form_address')

          expect(address_form.find("input[type='email']#order_email").value).to eq('cool_email@gmail.com')
          expect(address_form.find("input[type='text']#order_ship_address_attributes_city").value).to eq('Panamá')

          expect(address_form.find("input[type='text']#order_ship_address_attributes_name")['placeholder']).to eq('Nombre')
          expect(address_form.find("input[type='tel']#order_ship_address_attributes_phone")['placeholder']).to eq('Teléfono')
          expect(address_form.find("input[type='text']#order_ship_address_attributes_address1")['placeholder']).to eq('Dirección')
          expect(address_form.find("input[type='text']#order_ship_address_attributes_address2")['placeholder']).to eq('Punto de referencia')
          expect(address_form.find("select#order_ship_address_attributes_district_id option[value='#{bella_vista_district.id}']")).to have_text('Bella Vista')
          expect(address_form.find("select#order_ship_address_attributes_district_id option[value='#{san_francisco_district.id}']")).to have_text('San Francisco')
        end

        it 'has mandatory fields' do
          order = Spree::Order.last
          address_form = find('form#checkout_form_address')

          expect(order.state).to eq('address')
          expect(address_form.find("input[type='text']#order_ship_address_attributes_name").style('border-color')['border-color']).to eq('rgb(57, 171, 75)')
          expect(address_form.find('#missing-map-pin').style('color')['color']).to eq('rgba(51, 51, 58, 1)')
          expect(address_form.find('#map').style('border-color')['border-color']).to eq('rgba(0, 0, 0, 0)')

          address_form.find("input[type='submit']").click

          expect(order.reload.state).to eq('address')
          expect(address_form.find("input[type='text']#order_ship_address_attributes_name").style('border-color')['border-color']).to eq('rgb(253, 16, 21)')
          expect(address_form.find('#missing-map-pin').style('color')['color']).to eq('rgba(253, 16, 21, 1)')
          expect(address_form.find('#map').style('border-color')['border-color']).to eq('rgb(255, 0, 0)')
        end

        it 'updates latitude and longitude inputs when draging map marker and selecting districts' do
          address_form = find('form#checkout_form_address')
          address_latitude_input = address_form.find("input[type='hidden']#order_ship_address_attributes_latitude", visible: false)
          address_longitude_input = address_form.find("input[type='hidden']#order_ship_address_attributes_latitude", visible: false)
          map_marker = address_form.find('#map .mapboxgl-marker')

          expect(address_latitude_input.value).to be_blank
          expect(address_longitude_input.value).to be_blank

          map_marker.drag_to(address_form.find('#map'))

          expect(address_latitude_input.value).not_to be_blank
          expect(address_longitude_input.value).not_to be_blank

          address_form.find("select#order_ship_address_attributes_district_id option[value='#{bella_vista_district.id}']").select_option
          sleep(1)

          expect(address_latitude_input.value).to be_blank
          expect(address_longitude_input.value).to be_blank

          map_marker.drag_to(address_form.find('#map'))

          expect(address_latitude_input.value).not_to be_blank
          expect(address_longitude_input.value).not_to be_blank
        end

        it 'allows to save adress and send order to next step' do
          order = Spree::Order.last
          address_form = find('form#checkout_form_address')

          expect(order.state).to eq('address')

          address_form.find("input[type='text']#order_ship_address_attributes_name").set('Hari Seldon')
          address_form.find("input[type='tel']#order_ship_address_attributes_phone").set('0610111213')
          address_form.find("input[type='text']#order_ship_address_attributes_address1").set('23 Calle de aquí')
          address_form.find("input[type='text']#order_ship_address_attributes_address2").set('Al lado de allá')
          address_form.find("select#order_ship_address_attributes_district_id option[value='#{bella_vista_district.id}']").select_option
          sleep(1)
          address_form.find('#map .mapboxgl-marker').drag_to(address_form.find('#map'))
          address_form.find("input[type='submit']").click

          expect(order.reload.state).to eq('delivery')
          expect(order.email).to eq('cool_email@gmail.com')

          ship_address = order.ship_address
          expect(ship_address.name).to eq('Hari Seldon')
          expect(ship_address.phone).to eq('0610111213')
          expect(ship_address.address1).to eq('23 Calle de aquí')
          expect(ship_address.address2).to eq('Al lado de allá')
          expect(ship_address.city).to eq('Panamá')
          expect(ship_address.district).to eq(bella_vista_district)
          expect(ship_address.state).to eq(panama_state)
          expect(ship_address.country).to eq(panama_country)
          expect(ship_address.latitude.blank?).to be false
          expect(ship_address.longitude.blank?).to be false

          bill_address = order.bill_address
          expect(bill_address.name).to eq('Hari Seldon')
          expect(bill_address.phone).to eq('0610111213')
          expect(bill_address.address1).to eq('23 Calle de aquí')
          expect(bill_address.address2).to eq('Al lado de allá')
          expect(bill_address.city).to eq('Panamá')
          expect(bill_address.district).to eq(bella_vista_district)
          expect(bill_address.state).to eq(panama_state)
          expect(bill_address.country).to eq(panama_country)
          expect(bill_address.latitude.blank?).to be false
          expect(bill_address.longitude.blank?).to be false

          expect(current_url).to match(/\/checkout\/delivery/)
        end
      end
    end
  end
end
