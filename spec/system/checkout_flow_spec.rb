# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Product page', type: :system, js: true do
  let!(:store) { create(:smm_store) }
  let!(:product) do
    create(
      :smm_product,
      name: 'Cool product!',
      description: 'This is a cool product.',
      san_francisco_stock: 1,
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
  let!(:tax_category) { create(:tax_category, is_default: true, name: 'ITBMS', tax_code: 'itbms') }
  let!(:tax_rate) do
    create(
      :tax_rate,
      name: 'ITBMS',
      amount: 0.07,
      level: 'order',
      included_in_price: false,
      show_rate_in_label: true,
      zone: panama_country_zone,
      tax_categories: [tax_category]
    )
  end

  context 'when user is not logged in' do
    before do
      visit product_path(product)
      find(".add-to-cart .quantity-selector span[data-type='add']").click
      find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn").click
      find("[data-spec='add-to-cart-modal'] .modal-footer [data-spec='go-to-cart']").click
      find("button[name='checkout'][type='submit'].checkout-button").click
    end

    context 'checkout without registration' do
      before do
        find('form#checkout_form_registration input#order_email').set('cool_email@gmail.com')
        find("form#checkout_form_registration input[type='submit']").click
      end

      context 'address step' do
        it 'displays breadcrumb at address step' do
          expect(find('.progress-steps .current')).to have_text('DIRECCIÓN')
        end

        it 'displays order summary' do
          expect(find("#checkout-summary [data-spec='checkout-summary-products']")).to have_text("2 Productos\n$24.68")
          expect(find("#checkout-summary [data-spec='checkout-summary-tax']")).to have_text("ITBMS 7.00%\n$1.73")
          expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$26.41")
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

          expect(order.state).to eq('address')

          complete_address_step

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
          before { complete_address_step }

          it 'displays breadcrumb at delivery step' do
            expect(find('.progress-steps .completed')).to have_text('DIRECCIÓN')
            expect(find('.progress-steps .current')).to have_text('ENVÍO')
          end

          it 'displays order summary' do
            expect(find("#checkout-summary [data-spec='checkout-summary-products']")).to have_text("2 Productos\n$24.68")
            expect(find("#checkout-summary [data-spec='checkout-summary-tax']")).to have_text("ITBMS 7.00%\n$1.73")
            expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$26.41")
          end

          it 'displays Panama Zone 1 delivery options form' do
            delivery_form = find('form#checkout_form_delivery')

            expect(delivery_form.find('h5')).to have_text('ELEGIR MÉTODO DE ENVÍO')
            expect(delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery_shipping_method.id}']")).to have_text("Entrega a domicilio, en Ciudad de Panamá Zona 1\n$3.90")
            expect(delivery_form.find(".shipping-methods [data-spec='shipping-method-#{pickup_shipping_method.id}']")).to have_text("Recoger en la tienda de Bella Vista\n$0.00")
          end

          it 'allows to choose delivery and send order to next step' do
            order = Spree::Order.last

            expect(order.state).to eq('delivery')

            complete_delivery_step

            expect(order.reload.state).to eq('payment')
            expect(order.shipment_total).to eq(3.9)
            expect(order.promo_total).to eq(0)
            expect(order.shipments.first.cost).to eq(3.9)
            expect(order.shipments.first.promo_total).to eq(0)

            expect(current_url).to match(/\/checkout\/payment/)

            expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$3.90")
            expect(find('#checkout-summary')).not_to have_selector("[data-spec='checkout-summary-shipping-promotion']")
            expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$30.31")
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
            expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$26.41")
          end

          it 'equalizes shipments shipping methods and adds shipping cost to the first package only' do
            order = Spree::Order.last

            complete_delivery_step

            expect(order.reload.shipments.map(&:shipping_method).uniq).to eq([delivery_shipping_method])
            expect(order.shipments.map(&:cost)).to contain_exactly(3.9, 0)
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

              expect(find('form#checkout_form_delivery .free-shipping')).to have_text('¡Entrega gratis para pedidos arriba de $150.00!')

              complete_delivery_step

              expect(order.reload.state).to eq('payment')
              expect(order.shipment_total).to eq(3.9)
              expect(order.promo_total).to eq(-3.9)
              expect(order.shipments.first.cost).to eq(3.9)
              expect(order.shipments.first.promo_total).to eq(-3.9)

              expect(current_url).to match(/\/checkout\/payment/)

              expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$3.90")
              expect(find("#checkout-summary [data-spec='checkout-summary-shipping-promotion']")).to have_text("Promoción (Entrega Gratis)\n-$3.90")
              expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$192.62")
            end
          end
        end

        context 'when delivery is in Panama Zone 3' do
          before { complete_address_step(district: tocumen_district) }

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
              expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$202.12")
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
            TotalAmount: 30.31,
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

        before do
          # Set deterministrict uuid so that Spree::Payment can be retrieved
          allow(SecureRandom).to receive(:uuid).and_return(fake_uuid)

          complete_address_step
          complete_delivery_step
        end

        it 'displays breadcrumb at delivery step' do
          expect(find('.progress-steps .completed:first-child')).to have_text('DIRECCIÓN')
          expect(find('.progress-steps .completed:nth-child(2)')).to have_text('ENVÍO')
          expect(find('.progress-steps .current')).to have_text('PAGO')
        end

        it 'displays order summary' do
          expect(find("#checkout-summary [data-spec='checkout-summary-products']")).to have_text("2 Productos\n$24.68")
          expect(find("#checkout-summary [data-spec='checkout-summary-tax']")).to have_text("ITBMS 7.00%\n$1.73")
          expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$3.9")
          expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$30.31")
        end

        it 'displays payment form' do
          payment_form = find('form#checkout_form_payment')

          expect(payment_form.find('.payment-icons')).to have_selector("svg[data-spec='visa-icon']")
          expect(payment_form.find('.payment-icons')).to have_selector("svg[data-spec='master-icon']")
          expect(payment_form.find(".card_name input[type='text']#name_on_card_#{payment_method.id}")['placeholder']).to eq('Nombre en la tarjeta')
          expect(payment_form.find(".card_number input[type='tel']#card_number")['placeholder']).to eq('Número de tarjeta')
          expect(payment_form.find('.card_number')).to have_selector("svg[data-spec='lock-icon']")
          expect(payment_form.find('.card_number .has-tooltip .tooltip-text', visible: false)).to have_text(:all, 'Todas las transacciones están aseguradas')
          expect(payment_form.find(".card_expiration input[type='tel']#card_expiry")['placeholder']).to eq('MM / YY')
          expect(payment_form.find(".card_code input[type='tel']#card_code")['placeholder']).to eq('Código CVV de la tarjeta')
          expect(payment_form.find('.card_code .has-tooltip .tooltip-text', visible: false)).to have_text(:all, 'Código de seguridad de 3 números que se encuentra normalmente detras de su tarjeta. Las tarjetas American Expres tienen un código de 4 números en el frente.')
        end

        context 'when payment authorization is successfull' do
          # We doesn't deal with the case where payment doesn't have 3D Secure because it will result in the same test
          # Indeed without 3DS the flow is the same but instead of having to fill the 3DS form (like we mimic here with a simple submit button),
          # the payment platform directly redirect to /three_d_secure_response endpoint with a success payload

          let(:fake_sale_response_payload) do
            {
              TransactionType: 2,
              Approved: false,
              TransactionIdentifier: fake_uuid,
              TotalAmount: 30.31,
              CurrencyCode: '840',
              IsoResponseCode: 'SP4',
              ResponseMessage: 'SPI Preprocessing complete',
              OrderIdentifier: fake_order_identifier,
              RedirectData: three_ds_html_form,
              SpiToken: fake_spi_token
            }
          end
          let(:three_ds_html_form) { "<html><body><form method='post' action='/checkout/three_d_secure_response'><p>Fake 3ds form<p><input type='hidden' name='Response' value='#{fake_three_d_secure_response_payload.to_json}'><input type='submit'></form></body></html>" }
          let(:fake_payment_response_payload) do
            {
              TransactionType: 2,
              Approved: true,
              AuthorizationCode: '123456',
              TransactionIdentifier: fake_uuid,
              TotalAmount: 30.31,
              CurrencyCode: '840',
              RRN: '409521515533',
              CardBrand: 'Visa',
              IsoResponseCode: '00',
              ResponseMessage: 'Transaction is approved',
              PanToken: '2r7ihhjhuzinrgtyk3rskqt6zrluzcazs3k8otao4m7o77djfy',
              OrderIdentifier: fake_order_identifier
            }
          end

          context 'when 3D Secure is successfull' do
            let(:fake_three_d_secure_response_payload) do
              {
                TransactionType: 2,
                Approved: false,
                TransactionIdentifier: fake_uuid,
                TotalAmount: 30.31,
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

            before do
              stub_request(:post, /\.ptranz\.com\/api\/spi\/sale/)
                .with(body: hash_including(expected_payment_payload))
                .to_return(
                  status: 200,
                  body: fake_sale_response_payload.to_json
                )

              stub_request(:post, /\.ptranz\.com\/api\/spi\/payment/)
                .with(body: fake_spi_token.to_json)
                .to_return(
                  status: 200,
                  body: fake_payment_response_payload.to_json
                )
            end

            it 'allows to save payment send order to next step' do
              complete_payment_step
              expect(current_url).to match(/\/checkout\/update\/payment/)
              expect(find('form')).to have_text('Fake 3ds form')

              find("form input[type='submit']").click

              order = Spree::Order.last
              expect(current_url).to match(/\/orders\/#{order.number}\/token\/#{order.guest_token}/)
              expect(order.state).to eq('complete')
            end

            it 're-sets guest token cookie when it gets lost after 3D Secure in order not to loose the current order' do
              complete_payment_step
              page.driver.browser.manage.delete_cookie('guest_token')

              find("form input[type='submit']").click

              order = Spree::Order.last
              expect(current_url).to match(/\/orders\/#{order.number}\/token\/#{order.guest_token}/)
              expect(order.state).to eq('complete')
            end

            it 'sends an error to Sentry and redirects to cart with an error message when payment is lost after 3D Secure' do
              sentry_scope_double = double('Sentry::Scope', set_context: nil)
              allow(Sentry).to receive(:configure_scope).and_yield(sentry_scope_double)

              expect(sentry_scope_double).to receive(:set_context).with(
                'Extra data',
                {
                  error: /Couldn't find Spree::Payment/,
                  retrieved_payment_uuid: fake_uuid,
                  params: fake_three_d_secure_response_payload.to_json
                }
              )
              expect(Sentry).to receive(:capture_message).with('Error returning from 3DSecure')

              complete_payment_step

              Spree::Payment.destroy_all

              find("form input[type='submit']").click

              expect(current_url).to match(/carrito/)
              expect(find('#flash')).to have_text('ubo un problema procesando su pedido. Su pago no fue debitado. Por favor inténtelo de nuevo, y si el problema sigue contacte a Salva Mi Máquina.')
            end
          end

          context 'when 3D Secure fails' do
            let(:fake_three_d_secure_response_payload) do
              {
                TransactionType: 2,
                Approved: false,
                TransactionIdentifier: fake_uuid,
                TotalAmount: 30.31,
                CurrencyCode: '840',
                CardBrand: 'Visa',
                IsoResponseCode: '3D0',
                ResponseMessage: '3D-Secure error',
                RiskManagement: {
                  ThreeDSecure: {
                    Xid: '63e6b68a-0392-43ee-a5b9-0672d64c9763',
                    AuthenticationStatus: 'N',
                    StatusReason: '01',
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

            before do
              stub_request(:post, /\.ptranz\.com\/api\/spi\/sale/)
                .with(body: hash_including(expected_payment_payload))
                .to_return(
                  status: 200,
                  body: fake_sale_response_payload.to_json
                )
            end

            it 'doesnt complete order, sends an error to Sentry and redirects to payment page with an error message' do
              order = Spree::Order.last
              sentry_scope_double = double('Sentry::Scope', set_context: nil)
              allow(Sentry).to receive(:configure_scope).and_yield(sentry_scope_double)

              expect(sentry_scope_double).to receive(:set_context).with(
                'Extra data',
                {
                  payment_gateway_iso_response_code: '3D0',
                  payment_gateway_3ds_status: 'N',
                  payment_gateway_error_message: '3D-Secure error',
                  payment_gateway_method_name: '3Ds Response',
                  order_number: order.number,
                  payment: hash_including(
                    {
                      'amount' => '30.31',
                      'avs_response' => nil,
                      'cvv_response_code' => nil,
                      'cvv_response_message' => nil,
                      'order_id' => order.id,
                      'payment_method_id' => payment_method.id,
                      'response_code' => 'SP4',
                      'source_type' => 'Spree::CreditCard',
                      'spi_token' => nil,
                      'state' => 'checkout',
                      'uuid' => fake_uuid
                    }
                  )
                }
              )
              expect(Sentry).to receive(:capture_message).with('Spree::PaymentMethod::BacCreditCard')

              complete_payment_step

              find("form input[type='submit']").click
              expect(current_url).to match(/\/checkout\/three_d_secure_response/)
              expect(find('#flash')).to have_text('Hubo un problema con su información de pago. Por favor, revísela e inténtelo de nuevo.')
              expect(order.reload.state).to eq('payment')
            end
          end
        end

        context 'when payment authorization fails' do
          let(:fake_sale_response_payload) do
            {
              TransactionType: 2,
              Approved: false,
              TransactionIdentifier: fake_uuid,
              TotalAmount: 30.31,
              CurrencyCode: '840',
              IsoResponseCode: '12',
              ResponseMessage: 'Invalid card/currency',
              OrderIdentifier: fake_order_identifier,
              RedirectData: '',
              SpiToken: fake_spi_token
            }
          end

          before do
            stub_request(:post, /\.ptranz\.com\/api\/spi\/sale/)
              .with(body: hash_including(expected_payment_payload))
              .to_return(
                status: 200,
                body: fake_sale_response_payload.to_json
              )
          end

          it 'doesnt complete order, sends an error to Sentry and redirects to payment page with an error message' do
            order = Spree::Order.last
            sentry_scope_double = double('Sentry::Scope', set_context: nil)
            allow(Sentry).to receive(:configure_scope).and_yield(sentry_scope_double)

            expect(sentry_scope_double).to receive(:set_context).with(
              'Extra data',
              {
                payment_gateway_iso_response_code: '12',
                payment_gateway_3ds_status: nil,
                payment_gateway_error_message: 'Invalid card/currency',
                payment_gateway_method_name: 'Sale',
                order_number: order.number,
                payment: hash_including(
                  {
                    'amount' => '30.31',
                    'avs_response' => nil,
                    'cvv_response_code' => nil,
                    'cvv_response_message' => nil,
                    'order_id' => order.id,
                    'payment_method_id' => payment_method.id,
                    'response_code' => nil,
                    'source_type' => 'Spree::CreditCard',
                    'spi_token' => nil,
                    'state' => 'checkout',
                    'uuid' => fake_uuid
                  }
                )
              }
            )
            expect(Sentry).to receive(:capture_message).with('Spree::PaymentMethod::BacCreditCard')

            complete_payment_step

            expect(current_url).to match(/\/checkout\/update\/payment/)
            expect(find('#flash')).to have_text('Hubo un problema con su información de pago. Por favor, revísela e inténtelo de nuevo.')
            expect(order.reload.state).to eq('payment')
          end
        end
      end

      context 'complete step' do
        let(:fake_uuid) { '0a0c4f98-c5d4-4c8c-b218-9a3d2ed51ed6' }
        let(:fake_sale_response_payload) { { IsoResponseCode: 'SP4', RedirectData: three_ds_html_form } }
        let(:fake_payment_response_payload) { { Approved: true } }
        let(:three_ds_html_form) { "<html><body><form method='post' action='/checkout/three_d_secure_response'><p>Fake 3ds form<p><input type='hidden' name='Response' value='#{fake_three_d_secure_response_payload.to_json}'><input type='submit'></form></body></html>" }
        let(:fake_three_d_secure_response_payload) do
          {
            TransactionIdentifier: fake_uuid,
            IsoResponseCode: '3D0',
            RiskManagement: { ThreeDSecure: { AuthenticationStatus: 'Y' } },
            SpiToken: '9t1dr3wjcns8n446qj9t7xgurnr5s01svn5y14p5avat43seb-3plyg9wt7wz'
          }
        end

        before do
          # Set deterministrict uuid so that Spree::Payment can be retrieved
          allow(SecureRandom).to receive(:uuid).and_return(fake_uuid)

          stub_request(:post, /\.ptranz\.com\/api\/spi\/sale/)
            .to_return(
              status: 200,
              body: fake_sale_response_payload.to_json
            )

          stub_request(:post, /\.ptranz\.com\/api\/spi\/payment/)
            .to_return(
              status: 200,
              body: fake_payment_response_payload.to_json
            )

          complete_address_step
        end

        it 'displays order summary' do
          complete_delivery_step
          complete_payment_step
          find("input[type='submit']").click # 3D Secure

          order = Spree::Order.last

          expect(find('.order-page__completed')).to have_text('¡Gracias por su pedido!')
          expect(find('h1')).to have_text("Número de orden: #{order.number}")

          payment_summary = find(".order-step[data-spec='payment-summary']")
          expect(payment_summary.find('h6')).to have_text('Información del pago')
          expect(payment_summary.find('.cc-type')).to have_text('Termina con: 5678')
          expect(payment_summary.find('.full-name')).to have_text('Hari Seldon')

          line_item = find(".line-item[data-id='#{order.line_items.first.id}']")
          expect(line_item.find('img')['src']).to eq("https://cloudinary.com/salvamimaquina/image/upload/c_fit,d_test:products:product-image-placeholder.jpg,h_150/v1/test/products/#{product.images.first.attachment.key}")
          expect(line_item.find('.line-item-quantity')).to have_text('Cantidad: 2')
          expect(line_item.find('.line-item-total')).to have_text('$24.68')

          checkout_summary = find('#checkout-summary')
          expect(checkout_summary.find('h3')).to have_text('RESUMEN DE PEDIDO')
          expect(checkout_summary.find("[data-spec='checkout-summary-products']")).to have_text("2 Productos\n$24.68")
          expect(checkout_summary.find("[data-spec='checkout-summary-tax']")).to have_text("ITBMS 7.00%\n$1.73")

          expect(find('#order-back-link a')).to have_text('REGRESAR A LA TIENDA')
          expect(find('#order-back-link a')['href']).to match(/http:\/\/.+\/\z/)
        end

        it 'triggers post purchase actions' do
          message_delivery_double = instance_double(ActionMailer::MessageDelivery)
          allow(OrderCustomMailer).to receive(:confirm_email).and_return(message_delivery_double).twice

          order = Spree::Order.last

          expect(SendInvoiceToRsJob).to receive(:perform_later).with(order)
          expect(OrderCustomMailer).to receive(:confirm_email).with(order)
          expect(OrderCustomMailer).to receive(:confirm_email).with(order, for_admin: true)
          expect(message_delivery_double).to receive(:deliver_later).twice
          expect(UpdateProductPurchaseCountJob).to receive(:perform_later).with(order)

          complete_delivery_step
          complete_payment_step
          find("input[type='submit']").click # 3D Secure
        end

        context 'when user chose delivery' do
          before do
            complete_delivery_step
            complete_payment_step
            find("input[type='submit']").click # 3D Secure
          end

          it 'displays delivery address' do
            order = Spree::Order.last

            address_summary = find(".order-step[data-spec='address-summary']")
            expect(address_summary.find('h6')).to have_text('Dirección de envío')
            expect(address_summary.find('.address .fn')).to have_text('Hari Seldon')
            expect(address_summary.find('.address .adr')).to have_text("23 Calle de aquí\nAl lado de allá\nPanamá 1 Bella Vista")
            expect(address_summary.find('.address .tel')).to have_text('Teléfono: 0610111213')

            expect(find(".order-step[data-spec='delivery-summary'] h6")).to have_text('Envío')
            expect(find(".order-step[data-spec='delivery-summary'] .delivery")).to have_text('Entrega a domicilio, en Ciudad de Panamá Zona 1')

            expect(find('#static-map')['data-mapbox-static-latitude-value']).to eq(order.ship_address.latitude.to_s)
            expect(find('#static-map')['data-mapbox-static-longitude-value']).to eq(order.ship_address.longitude.to_s)

            expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$3.9")
            expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$30.31")
          end
        end

        context 'when user chose pick up in store' do
          before do
            complete_delivery_step(delivery: false)
            complete_payment_step
            find("input[type='submit']").click # 3D Secure
          end

          it 'displays pickup store address' do
            expect(page).not_to have_selector(".order-step[data-spec='address-summary']")

            delivery_summary = find(".order-step[data-spec='delivery-summary']")
            expect(delivery_summary.find('h6')).to have_text('Envío')
            expect(delivery_summary.find('.delivery')).to have_text('Recoger en la tienda de Bella Vista')
            expect(delivery_summary.find('a')).to have_text('Dirección')
            expect(delivery_summary.find('a')['href']).to eq(pickup_shipping_method.google_map_link)

            expect(find('#static-map')['data-mapbox-static-latitude-value']).to eq(pickup_shipping_method.latitude.to_s)
            expect(find('#static-map')['data-mapbox-static-longitude-value']).to eq(pickup_shipping_method.longitude.to_s)

            expect(find("#checkout-summary [data-spec='checkout-summary-shipping']")).to have_text("Entrega\n$0.00")
            expect(find("#checkout-summary [data-spec='checkout-summary-total']")).to have_text("TOTAL\n$26.41")
          end
        end
      end
    end

    context 'checkout with registration' do
      let(:address) do
        create(
          :address,
          address1: '26 Calle cool',
          address2: 'Detras del palo de mango',
          city: 'Panama',
          phone: '+507111222',
          name: 'Cool User',
          state: panama_state,
          country: panama_country,
          district: bella_vista_district,
          latitude: 8.990457433505895,
          longitude: -79.52670864665536
        )
      end
      let!(:user) { create(:user, email: 'cool_email@gmail.com', password: '!Azerty123', ship_address: address) }

      before do
        find('form#new_spree_user input#spree_user_email').set('cool_email@gmail.com')
        find('form#new_spree_user input#spree_user_password').set('!Azerty123')
        find("form#new_spree_user input[type='submit']").click
      end

      it 'assigns order to user and pre-fill address form with user address' do
        sleep(1)
        expect(Spree::Order.last.user).to eq(user)

        address_form = find('form#checkout_form_address')

        expect(address_form.find("input[type='email']#order_email").value).to eq('cool_email@gmail.com')
        expect(address_form.find("input[type='text']#order_ship_address_attributes_city").value).to eq('Panamá')
        expect(address_form.find("input[type='text']#order_ship_address_attributes_name").value).to eq('Cool User')
        expect(address_form.find("input[type='tel']#order_ship_address_attributes_phone").value).to eq('507111222')
        expect(address_form.find("input[type='text']#order_ship_address_attributes_address1").value).to eq('26 Calle cool')
        expect(address_form.find("input[type='text']#order_ship_address_attributes_address2").value).to eq('Detras del palo de mango')
        expect(address_form.find("select#order_ship_address_attributes_district_id option[value='#{bella_vista_district.id}']")).to have_text('Bella Vista')
        expect(address_form.find("select#order_ship_address_attributes_district_id option[value='#{tocumen_district.id}']")).to have_text('Tocumen')
        expect(address_form.find("input[type='hidden']#order_ship_address_attributes_latitude", visible: false).value).to eq('8.990457433505895')
        expect(address_form.find("input[type='hidden']#order_ship_address_attributes_longitude", visible: false).value).to eq('-79.52670864665536')
      end
    end
  end

  context 'when user is already logged in' do
    let!(:user) { create(:user, email: 'cool_email@gmail.com', password: '!Azerty123') }

    before do
      visit login_path
      find('form#new_spree_user input#spree_user_email').set('cool_email@gmail.com')
      find('form#new_spree_user input#spree_user_password').set('!Azerty123')
      find("form#new_spree_user input[type='submit']").click
      sleep(1)

      visit product_path(product)
      find(".add-to-cart .quantity-selector span[data-type='add']").click
      find("#add-to-cart-form form[data-spec='line-items-cart'] button#add-to-cart-btn").click
      find("[data-spec='add-to-cart-modal'] .modal-footer [data-spec='go-to-cart']").click
      find("button[name='checkout'][type='submit'].checkout-button").click
    end

    it 'skip order registration step and directly brings user to address step' do
      sleep(1)

      expect(Spree::Order.last.user).to eq(user)
      expect(current_url).to match(match(/\/checkout\/address/))
      expect(find("form#checkout_form_address input[type='email']#order_email").value).to eq('cool_email@gmail.com')
    end
  end
end

def complete_address_step(district: bella_vista_district)
  address_form = find('form#checkout_form_address')
  address_form.find("input[type='text']#order_ship_address_attributes_name").set('Hari Seldon')
  address_form.find("input[type='tel']#order_ship_address_attributes_phone").set('0610111213')
  address_form.find("input[type='text']#order_ship_address_attributes_address1").set('23 Calle de aquí')
  address_form.find("input[type='text']#order_ship_address_attributes_address2").set('Al lado de allá')
  address_form.find("select#order_ship_address_attributes_district_id option[value='#{district.id}']").select_option
  sleep(2.5)
  address_form.find('#map .mapboxgl-marker').drag_to(address_form.find('#map'))
  address_form.find("input[type='submit']").click
end

def complete_delivery_step(delivery: true)
  delivery_form = find('form#checkout_form_delivery')
  delivery_form.find(".shipping-methods [data-spec='shipping-method-#{delivery ? delivery_shipping_method.id : pickup_shipping_method.id}']").click
  delivery_form.find("input[type='submit']").click
end

def complete_payment_step
  payment_form = find('form#checkout_form_payment')
  payment_form.find(".card_name input[type='text']#name_on_card_#{payment_method.id}").set('Hari Seldon')
  payment_form.find(".card_number input[type='tel']#card_number").set('12345678')
  payment_form.find(".card_expiration input[type='tel']#card_expiry").set((Date.today + 1.year).strftime('%m / %y'))
  payment_form.find(".card_code input[type='tel']#card_code").set('123')
  payment_form.find("input[type='submit']").click
end
