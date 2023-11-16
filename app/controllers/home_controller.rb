# frozen_string_literal: true

class HomeController < StoreController
  invisible_captcha only: %i[create_user_message create_corporate_client_message], honeypot: :names
  layout 'spree/layouts/spree_application'

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
    @slider = Slider.find_by(location: :contact)
    generate_business_hours
  end

  def corporate_clients
    @user_message = UserMessage.new
    find_corporate_clients_sliders

    @corporate_services = corporate_services
  end

  def create_user_message
    @user_message = UserMessage.new(user_message_params)
    if @user_message.save
      AdminNotificationMailer.user_message_email(@user_message).deliver_later
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
      AdminNotificationMailer.corporate_message_email(@user_message).deliver_later
      flash.notice = t('message_sent')
      redirect_to corporate_clients_path
    else

      @corporate_services = corporate_services
      find_corporate_clients_sliders
      render :corporate_clients
    end
  end

  def about
    @slider = Slider.find_by(location: :about)
  end

  def shipping_informations
    @shipping_methods = Spree::ShippingMethod.includes(:calculator, zones: [zone_members: :zoneable]).where(service_level: 'delivery').order(:code)
    @stores = Spree::ShippingMethod.where(service_level: nil)
    @free_shipping_threshold = Spree::Promotion::FREE_SHIPPING_THRESHOLD
  end

  def payment_methods; end

  def identify_your_model
    identify_model_links = {
      ipad: 'https://support.apple.com/es-es/HT201471',
      iphone: 'https://support.apple.com/es-es/HT201296',
      mac: 'https://support.apple.com/es-es/HT201581'
    }

    @model_types = %w[iPhone iPad Mac].map do |model_type|
      {
        name: model_type,
        image: Spree::Taxon.find_by(name: model_type).icon,
        identify_model_link: identify_model_links[model_type.downcase.to_sym]
      }
    end
  end

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

  def find_corporate_clients_sliders
    @slider_1 = Slider.find_by(location: :corporate_clients_1)
    @slider_2 = Slider.find_by(location: :corporate_clients_2)
  end

  # TODO: improve how we deal with this data... Maybe create a CorporateService model?
  def corporate_services
    %w[
      repair
      customer_service
      emergency
      credit
      quality
      delivery
    ]
  end
end
