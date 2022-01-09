# frozen_string_literal: true

module Spree
  module HomeControllerDecorator
    extend ActiveSupport::Concern

    prepended do
      invisible_captcha only: %i[create_user_message create_corporate_client_message]
      layout 'spree/layouts/spree_application'
    end

    def index
      @products = Spree::Product
                  .includes(variants_including_master: [prices: :active_sale_prices, images: [attachment_attachment: :blob]])
                  .where(highlight: true)
                  .limit(4)
      @slider = Slider.find_by(location: :home_page)

      respond_to do |format|
        format.html { render layout: 'homepage' }
      end
    end

    def contact
      @user_message = UserMessage.new
      generate_business_hours
    end

    def corporate_clients
      @user_message = UserMessage.new
      find_corporate_clients_banner_and_slider

      # TODO: improve how we deal with this data... Maybe create a CorporateService model?
      @corporate_services = %w[
        repair
        customer_service
        emergency
        credit
        quality
        delivery
      ]
    end

    def create_user_message
      @user_message = UserMessage.new(user_message_params)
      if @user_message.save
        UserMessageMailer.contact_message(
          user_message: @user_message,
          subject: 'New Message from salvamimaquina.com contact form',
          to: 'administracion@salvamimaquina.com'
        ).deliver_later
        flash.notice = t('message_sent')
        redirect_to contact_path
      else
        generate_business_hours
        render :contact
      end
    end

    def create_corporate_client_message
      @user_message = UserMessage.new(user_message_params)
      if @user_message.save
        UserMessageMailer.contact_message(
          user_message: @user_message,
          subject: 'New message from salvamimaquina.com corporate client contact form',
          to: ['administracion@salvamimaquina.com', 'quentin@salvamimaquina.com']
        ).deliver_later
        flash.notice = t('message_sent')
        redirect_to corporate_clients_path
      else
        find_corporate_clients_banner_and_slider
        render :corporate_clients
      end
    end

    def about; end

    def shipping_informations
      @shipping_methods = Spree::ShippingMethod.includes(:calculator, zones: [zone_members: :zoneable]).where(service_level: 'delivery').order(:code)
      @stores = Spree::ShippingMethod.where(service_level: nil)
      @free_shipping_threshold = Spree::Promotion::FREE_SHIPPING_THRESHOLD
    end

    def payment_methods; end

    private

    def user_message_params
      params.require(:user_message).permit(:name, :email, :message)
    end

    def generate_business_hours
      business_hours = RepairShoprApi::V1::Base.get_business_hours.map do |business_hour|
        business_hour.symbolize_keys!
        unless business_hour[:closed]
          business_hour[:start] = business_hour[:start].to_time.strftime('%I:%M%p')
          business_hour[:end] = business_hour[:end].to_time.strftime('%I:%M%p')
        end
        business_hour
      end

      @business_hours = business_hours.sort_by! { |day| %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].index(day[:day]) }
    end

    def find_corporate_clients_banner_and_slider
      @banner = Banner.find_by(location: :corporate_clients)
      @slider = Slider.find_by(location: :corporate_clients)
    end

    Spree::HomeController.prepend self
  end
end
