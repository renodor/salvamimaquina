# frozen_string_literal:true

module Spree
  class TradeInRequestsController < Spree::StoreController
    def new
      set_form_variables
      @trade_in_request = TradeInRequest.new
      @slider = Slider.find_by(location: :trade_in)
    end

    def create
      @trade_in_request = TradeInRequest.create(trade_in_request_params)
      if @trade_in_request.valid?
        TradeInRequestMailer.confirmation_email(@trade_in_request).deliver_later
        AdminNotificationMailer.trade_in_request_email(@trade_in_request).deliver_later
        redirect_to trade_in_request_path(@trade_in_request.token)
      else
        set_form_variables
        @show_fields = true
        render :new
      end
    end

    def show
      @trade_in_request = TradeInRequest.find_by(token: params[:token])
      redirect_to new_trade_in_request_path and return unless @trade_in_request

      @variant = @trade_in_request.variant
      @coupon_validity = TradeInRequest::COUPON_VALIDITY_DAYS
      @coupon_validity_text = "#{@coupon_validity} #{I18n.t('day', count: @coupon_validity).downcase}"
      @shop_name = @trade_in_request.shop.titleize
    end

    def variant_infos
      variant = Spree::Variant.find(params[:variant_id])
      render json: {
        tradeInIsValid: params[:trade_in_max_value].to_f < variant.price,
        name: variant.name,
        price: helpers.number_to_currency(variant.price),
        options: variant.options_text,
        imageTag: helpers.cl_image_tag_with_folder(variant.images.first&.attachment, width: 200, crop: :fill, model: Spree::Image, alt: "#{variant.product.name} - #{variant.options_text}"),
        minValue: helpers.number_to_currency(variant.price - params[:trade_in_max_value].to_f),
        maxValue: helpers.number_to_currency(variant.price - params[:trade_in_min_value].to_f)
      }
    end

    private

    def set_form_variables
      @trade_in_categories = TradeInCategory.all.order(:name)
      @trade_in_models = TradeInModel.all.includes(:trade_in_category).order(:name)
      @accessories_taxon_id = Spree::Taxon.find_by(name: 'Accesorios').id
      @taxons = Taxon.where.not(id: @accessories_taxon_id).where(depth: 1)
      @products = Spree::Product.includes(:variants, :master, :taxons, :classifications).in_taxons(@taxons).order(:name)
      @variants = Spree::Variant.where(is_master: false, product: @products).includes(:product, [option_values: :option_type]).order(:product_id)
    end

    def trade_in_request_params
      params.require(:trade_in_request).permit(:variant_id, :model_name_with_options, :model_min_value, :model_max_value, :name, :email, :phone, :shop, :comment)
    end
  end
end
