# frozen_string_literal: true

module Spree
  module HomeControllerDecorator
    def self.prepended(base)
      base.layout 'spree/layouts/spree_application'
    end

    def index
      @products = Spree::Product
                  .includes(variants_including_master: [prices: :active_sale_prices, images: [attachment_attachment: :blob]])
                  .where(highlight: true)
                  .limit(4)

      respond_to do |format|
        format.html { render layout: 'homepage' }
      end
    end

    def contact
      @business_hours = generate_business_hours
      @user_message = UserMessage.new
    end

    def create_user_message
      @user_message = UserMessage.new(user_message_params)
      if @user_message.save
        UserMessageMailer.contact_message(@user_message).deliver_later
        flash.notice = t('message_sent')
        redirect_to contact_path
      else
        @business_hours = generate_business_hours
        render :contact
      end
    end

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

      business_hours.sort_by! { |day| %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].index(day[:day]) }
    end

    Spree::HomeController.prepend self
  end
end
