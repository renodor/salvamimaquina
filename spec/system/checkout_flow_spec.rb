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
  let!(:product2) { create(:smm_product, name: 'Expensive product', bella_vista_stock: 1) }
  let!(:price) { create(:price, amount: 12.34, variant: product.master) }
  let!(:price2) { create(:price, amount: 155.34, variant: product2.master) }
  let!(:image) { create(:smm_image, viewable: product.master, attachment: Rails.root.join('spec', 'fixtures', 'product_images', 'iphone-14a.jpg').open) }
  let!(:cross_sell_relation_type) { create(:cross_sell_relation_type) }
  let!(:panama_country) { create(:country, name: 'Panama', iso_name: 'PANAMA', iso: 'PA', iso3: 'PAN') }
  let!(:panama_state) { create(:state, name: 'Panamá', country: panama_country) }
  let!(:bella_vista_district) { create(:district, name: 'Bella Vista', latitude: 8.983972, longitude: -79.526022, state: panama_state) }
  let!(:tocumen_district) { create(:district, name: 'Tocumen', latitude: 9.071253, longitude: -79.388304, state: panama_state) }
  let!(:panama_zone1) { create(:zone, name: 'Panama Zone 1') }
  let!(:panama_zone3) { create(:zone, name: 'Panama Zone 3') }
  let!(:panama_country_zone) { create(:zone, name: 'Panama') }
  let!(:panama_zone_member1) { create(:zone_member, zoneable: bella_vista_district, zone: panama_zone1) }
  let!(:panama_zone_member2) { create(:zone_member, zoneable: tocumen_district, zone: panama_zone3) }
  let!(:panama_zone_member_country) { create(:zone_member, zoneable: panama_country, zone: panama_country_zone) }
  let!(:delivery_calculator) { create(:calculator, type: 'Spree::Calculator::Shipping::CustomShippingCalculator', preferences: { amount: 3.9 }) }
  let!(:delivery_calculator2) { create(:calculator, type: 'Spree::Calculator::Shipping::CustomShippingCalculator', preferences: { amount: 9.5 }) }
  let!(:pickup_calculator) { create(:calculator, type: 'Spree::Calculator::Shipping::FlatPercentItemTotal', preferences: { flat_percent: 0, amount: 0 }) }
  let!(:delivery_shipping_method) do
    create(
      :shipping_method,
      name: 'Panama Zone 1',
      admin_name: 'panama_zone_1',
      code: '1',
      service_level: 'delivery',
      zones: [panama_zone1],
      calculator: delivery_calculator
    )
  end
  let!(:delivery_shipping_method2) do
    create(
      :shipping_method,
      name: 'Panama Zone 3',
      admin_name: 'panama_zone_3',
      code: '3',
      service_level: 'delivery',
      zones: [panama_zone3],
      calculator: delivery_calculator2
    )
  end
  let!(:pickup_shipping_method) do
    create(
      :shipping_method,
      name: 'Pick-up in store: Bella Vista',
      admin_name: 'Bella Vista',
      code: nil,
      service_level: nil,
      latitude: 8.9805139,
      longitude: -79.5268223,
      google_map_link: 'https://g.page/SalvaMiMaquina?share',
      zones: [panama_country_zone],
      calculator: pickup_calculator
    )
  end
  let!(:free_shipping_promo) { create(:free_shipping_promotion) }
  let!(:payment_method) do
    create(
      :payment_method,
      type: 'Spree::PaymentMethod::BacCreditCard',
      name: 'Credit Card',
      auto_capture: true,
      preferences: { server: 'fac', test_mode: false }
    )
  end

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
          expect(address_form.find("select#order_ship_address_attributes_district_id option[value='#{tocumen_district.id}']")).to have_text('Tocumen')
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

      context 'delivery step' do
        context 'when order ship address is in Panama Zone 1 or 2' do
          before do
            address_form = find('form#checkout_form_address')

            address_form.find("input[type='text']#order_ship_address_attributes_name").set('Hari Seldon')
            address_form.find("input[type='tel']#order_ship_address_attributes_phone").set('0610111213')
            address_form.find("input[type='text']#order_ship_address_attributes_address1").set('23 Calle de aquí')
            address_form.find("input[type='text']#order_ship_address_attributes_address2").set('Al lado de allá')
            address_form.find("select#order_ship_address_attributes_district_id option[value='#{bella_vista_district.id}']").select_option
            sleep(1)
            address_form.find('#map .mapboxgl-marker').drag_to(address_form.find('#map'))
            address_form.find("input[type='submit']").click
          end

          it 'displays breadcrumb at delivery step' do
            expect(find('.progress-steps .completed')).to have_text('DIRECCIÓN')
            expect(find('.progress-steps .current')).to have_text('ENVÍO')
          end

          it 'displays order summary' do
            expect(find("#checkout-summary [data-spec='checkout-summary-products']")).to have_text("2 Productos\n$24.68")
            expect(find('#checkout-summary #summary-order-total')).to have_text('$24.68')
          end

          it 'displays Panama Zone 1 delivery options form' do
            delivery_form = find('form#checkout_form_delivery')

            expect(delivery_form.find('h5')).to have_text('ELEGIR MÉTODO DE ENVÍO')
            expect(delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery_shipping_method.id}']")).to have_text("Entrega a domicilio, en Ciudad de Panamá Zona 1\n$3.90")
            expect(delivery_form.find(".shipping-methods [data-spec='shipping-method-#{pickup_shipping_method.id}']")).to have_text("Recoger en la tienda de Bella Vista\n$0.00")
          end

          it 'allows to choose delivery and send order to next step' do
            order = Spree::Order.last
            delivery_form = find('form#checkout_form_delivery')

            expect(order.state).to eq('delivery')

            delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery_shipping_method.id}']").click
            delivery_form.find("input[type='submit']").click

            expect(order.reload.state).to eq('payment')
            expect(order.shipment_total).to eq(3.9)
            expect(order.promo_total).to eq(0)
            expect(order.shipments.first.cost).to eq(3.9)
            expect(order.shipments.first.promo_total).to eq(0)

            expect(current_url).to match(/\/checkout\/payment/)

            expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$3.90")
            expect(find('#checkout-summary')).not_to have_selector("[data-spec='checkout-summary-shipping-promotion']")
            expect(find('#checkout-summary #summary-order-total')).to have_text('$28.58')
          end

          it 'allows to choose pick up in store and send order to next step' do
            order = Spree::Order.last
            delivery_form = find('form#checkout_form_delivery')

            expect(order.state).to eq('delivery')

            delivery_form.find(".shipping-methods [data-spec='shipping-method-#{pickup_shipping_method.id}']").click
            delivery_form.find("input[type='submit']").click

            expect(order.reload.state).to eq('payment')
            expect(order.shipment_total).to eq(0)
            expect(order.shipments.first.cost).to eq(0)

            expect(current_url).to match(/\/checkout\/payment/)

            expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$0.00")
            expect(find('#checkout-summary #summary-order-total')).to have_text('$24.68')
          end

          context 'when order total is greater or equal than free shipping threshold' do
            before do
              visit product_path(product2)
              find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn").click
              sleep(0.5)
              visit checkout_path
              find("form#checkout_form_address input[type='submit']").click
            end

            it 'offers free shipping' do
              order = Spree::Order.last
              delivery_form = find('form#checkout_form_delivery')

              expect(delivery_form.find('.free-shipping')).to have_text('¡Entrega gratis para pedidos arriba de $150.00!')

              delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery_shipping_method.id}']").click
              delivery_form.find("input[type='submit']").click

              expect(order.reload.state).to eq('payment')
              expect(order.shipment_total).to eq(3.9)
              expect(order.promo_total).to eq(-3.9)
              expect(order.shipments.first.cost).to eq(3.9)
              expect(order.shipments.first.promo_total).to eq(-3.9)

              expect(current_url).to match(/\/checkout\/payment/)

              expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$3.90")
              expect(find("#checkout-summary [data-spec='checkout-summary-shipping-promotion']")).to have_text("Promoción (Entrega Gratis)\n-$3.90")
              expect(find('#checkout-summary #summary-order-total')).to have_text('$180.02')
            end
          end
        end

        context 'when delivery is in Panama Zone 3' do
          before do
            address_form = find('form#checkout_form_address')

            address_form.find("input[type='text']#order_ship_address_attributes_name").set('Hari Seldon')
            address_form.find("input[type='tel']#order_ship_address_attributes_phone").set('0610111213')
            address_form.find("input[type='text']#order_ship_address_attributes_address1").set('23 Calle muy lejos')
            address_form.find("input[type='text']#order_ship_address_attributes_address2").set('Muy lejos de allá')
            address_form.find("select#order_ship_address_attributes_district_id option[value='#{tocumen_district.id}']").select_option
            sleep(2)
            address_form.find('#map .mapboxgl-marker').drag_to(address_form.find('#map'))
            address_form.find("input[type='submit']").click
          end

          it 'displays Panama Zone 3 delivery options form' do
            delivery_form = find('form#checkout_form_delivery')

            expect(delivery_form.find('h5')).to have_text('ELEGIR MÉTODO DE ENVÍO')
            expect(delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery_shipping_method2.id}']")).to have_text("Entrega a domicilio, en Ciudad de Panamá Zona 3\n$9.50")
            expect(delivery_form.find(".shipping-methods [data-spec='shipping-method-#{pickup_shipping_method.id}']")).to have_text("Recoger en la tienda de Bella Vista\n$0.00")
          end

          context 'when order total is greater or equal than free shipping threshold' do
            before do
              visit product_path(product2)
              find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn").click
              sleep(0.5)
              visit checkout_path
              find("form#checkout_form_address input[type='submit']").click
            end

            it 'doesnt offer free shipping' do
              order = Spree::Order.last
              delivery_form = find('form#checkout_form_delivery')

              expect(delivery_form).not_to have_selector('.free-shipping')

              delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery_shipping_method2.id}']").click
              delivery_form.find("input[type='submit']").click

              expect(order.reload.state).to eq('payment')
              expect(order.shipment_total).to eq(9.5)
              expect(order.promo_total).to eq(0)
              expect(order.shipments.first.cost).to eq(9.5)
              expect(order.shipments.first.promo_total).to eq(0)

              expect(current_url).to match(/\/checkout\/payment/)

              expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$9.50")
              expect(find('#checkout-summary')).not_to have_selector("[data-spec='checkout-summary-shipping-promotion']")
              expect(find('#checkout-summary #summary-order-total')).to have_text('$189.52')
            end
          end
        end
      end

      context 'payment step' do
        let(:fake_order_identifier) { 'R972216800-JG2LQAWJ' }
        let(:fake_uuid) { '0a0c4f98-c5d4-4c8c-b218-9a3d2ed51ed6' }
        let(:fake_spi_token) { '9t1dr3wjcns8n446qj9t7xgurnr5s01svn5y14p5avat43seb-3plyg9wt7wz' }
        let(:expected_payment_payload) do
          {
            TotalAmount: 28.58,
            CurrencyCode: 840,
            ThreeDSecure: true,
            Source: {
              CardPan: '12345678',
              CardCvv: '123',
              CardExpiration: '2504',
              CardholderName: 'Hari Seldon'
            },
            BillingAddress: {
              FirstName: 'Hari',
              LastName: 'Seldon',
              Line1: '23 Calle de aquí',
              Line2: 'Al lado de allá',
              City: 'Panamá',
              County: 'Panamá',
              CountryCode: 591,
              EmailAddress: 'cool_email@gmail.com'
            }
          }
        end
        let(:fake_three_d_secure_payload) do
          {
            TransactionType: 2,
            Approved: false,
            TransactionIdentifier: fake_uuid,
            TotalAmount: 28.58,
            CurrencyCode: '840',
            IsoResponseCode: 'SP4',
            ResponseMessage: 'SPI Preprocessing complete',
            OrderIdentifier: fake_order_identifier,
            RedirectData: "<html><body><form method='post' action='/checkout/three_d_secure_response'><p>Fake 3ds form<p><input type='hidden' name='Response' value='#{fake_three_d_secure_response_payload.to_json}'><input type='submit'></form></body></html>",
            SpiToken: fake_spi_token
          }
        end
        let(:fake_three_d_secure_response_payload) do
          {
            TransactionType: 2,
            Approved: false,
            TransactionIdentifier: fake_uuid,
            TotalAmount: 28.58,
            CurrencyCode: '840',
            CardBrand: 'Visa',
            IsoResponseCode: '3D0',
            ResponseMessage: '3D-Secure complete',
            RiskManagement: {
              ThreeDSecure: {
                Eci: '05',
                Cavv: 'AJkBAGaAYwdYQHEHFIBjAAAAAAA=',
                Xid: '63e6b68a-0392-43ee-a5b9-0672d64c9763',
                AuthenticationStatus: 'Y',
                ProtocolVersion: '2.1.0',
                FingerprintIndicator: 'U',
                DsTransId: '731ee708-1f9f-42b0-88fd-fca707f7bd32',
                ResponseCode: '3D0',
                CardholderInfo: 'Additional authentication is needed for this transaction, please contact(Issuer Name) at xxx - xxx - xxxx.'
              }
            },
            PanToken: '2r7ihhjhuzinrgtyk3rskqt6zrluzcazs3k8otao4m7o77djfy',
            OrderIdentifier: fake_order_identifier,
            SpiToken: fake_spi_token
          }
        end
        let(:fake_payment_response_payload) do
          {
            TransactionType: 2,
            Approved: true,
            AuthorizationCode: '123456',
            TransactionIdentifier: fake_uuid,
            TotalAmount: 28.58,
            CurrencyCode: '840',
            RRN: '409521515533',
            CardBrand: 'Visa',
            IsoResponseCode: '00',
            ResponseMessage: 'Transaction is approved',
            PanToken: '2r7ihhjhuzinrgtyk3rskqt6zrluzcazs3k8otao4m7o77djfy',
            OrderIdentifier: fake_order_identifier
          }
        end

        before do
          # Set deterministrict uuid so that Spree::Payment can be retrieved
          allow(SecureRandom).to receive(:uuid).and_return(fake_uuid)

          address_form = find('form#checkout_form_address')

          address_form.find("input[type='text']#order_ship_address_attributes_name").set('Hari Seldon')
          address_form.find("input[type='tel']#order_ship_address_attributes_phone").set('0610111213')
          address_form.find("input[type='text']#order_ship_address_attributes_address1").set('23 Calle de aquí')
          address_form.find("input[type='text']#order_ship_address_attributes_address2").set('Al lado de allá')
          address_form.find("select#order_ship_address_attributes_district_id option[value='#{bella_vista_district.id}']").select_option
          sleep(1)
          address_form.find('#map .mapboxgl-marker').drag_to(address_form.find('#map'))
          address_form.find("input[type='submit']").click

          delivery_form = find('form#checkout_form_delivery')
          delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery_shipping_method.id}']").click
          delivery_form.find("input[type='submit']").click
        end

        it 'displays breadcrumb at delivery step' do
          expect(find('.progress-steps .completed:first-child')).to have_text('DIRECCIÓN')
          expect(find('.progress-steps .completed:nth-child(2)')).to have_text('ENVÍO')
          expect(find('.progress-steps .current')).to have_text('PAGO')
        end

        it 'displays order summary' do
          expect(find("#checkout-summary [data-spec='checkout-summary-products']")).to have_text("2 Productos\n$24.68")
          expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$3.9")
          expect(find('#checkout-summary #summary-order-total')).to have_text('$28.58')
        end

        it 'displays payment form' do
          payment_form = find('form#checkout_form_payment')

          expect(payment_form.find('.payment-icons')).to have_selector("svg[data-spec='visa-icon']")
          expect(payment_form.find('.payment-icons')).to have_selector("svg[data-spec='master-icon']")
          expect(payment_form.find(".card_name input[type='text']#name_on_card_1")['placeholder']).to eq('Nombre en la tarjeta')
          expect(payment_form.find(".card_number input[type='tel']#card_number")['placeholder']).to eq('Número de tarjeta')
          expect(payment_form.find('.card_number')).to have_selector("svg[data-spec='lock-icon']")
          expect(payment_form.find('.card_number .has-tooltip .tooltip-text', visible: false)).to have_text(:all, 'Todas las transacciones están aseguradas')
          expect(payment_form.find(".card_expiration input[type='tel']#card_expiry")['placeholder']).to eq('MM / YY')
          expect(payment_form.find(".card_code input[type='tel']#card_code")['placeholder']).to eq('Código CVV de la tarjeta')
          expect(payment_form.find('.card_code .has-tooltip .tooltip-text', visible: false)).to have_text(:all, 'Código de seguridad de 3 números que se encuentra normalmente detras de su tarjeta. Las tarjetas American Expres tienen un código de 4 números en el frente.')
        end

        it 'allows save payment send order to next step' do
          stub_request(:post, /\.ptranz\.com\/api\/spi\/sale/)
            .with(body: hash_including(expected_payment_payload))
            .to_return(
              status: 200,
              body: fake_three_d_secure_payload.to_json
            )

          stub_request(:post, /\.ptranz\.com\/api\/spi\/payment/)
            .with(body: fake_spi_token.to_json)
            .to_return(
              status: 200,
              body: fake_payment_response_payload.to_json
            )

          payment_form = find('form#checkout_form_payment')

          payment_form.find(".card_name input[type='text']#name_on_card_1").set('Hari Seldon')
          payment_form.find(".card_number input[type='tel']#card_number").set('12345678')
          payment_form.find(".card_expiration input[type='tel']#card_expiry").set((Date.today + 1.year).strftime('%m / %y'))
          payment_form.find(".card_code input[type='tel']#card_code").set('123')
          payment_form.find("input[type='submit']").click

          expect(current_url).to match(/\/checkout\/update\/payment/)
          expect(find('form')).to have_text('Fake 3ds form')
          find("form input[type='submit']").click

          binding.pry
        end
      end
    end
  end
end
