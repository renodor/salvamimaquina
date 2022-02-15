# frozen_string_literal:true

module Spree
  class TradeInRequestsController < Spree::StoreController
    def new
      set_form_variables
      @trade_in_request = TradeInRequest.new
    end

    def create
      @trade_in_request = TradeInRequest.create(trade_in_request_params)
      if @trade_in_request.valid?
        # ReparationRequestMailer.reparation_request_message(reparation_request: @reparation_request).deliver_later
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

      @trade_in_model = @trade_in_request.trade_in_model
      @variant = @trade_in_request.variant
      @coupon_validity_days = TradeInRequest::COUPON_VALIDITY_DAYS
    end

    def variant_infos
      variant = Spree::Variant.find(params[:variant_id])
      render json: {
        tradeInIsValid: params[:trade_in_max_value].to_f < variant.price,
        name: variant.name,
        price: helpers.number_to_currency(variant.price),
        options: variant.options_text,
        imageTag: helpers.cl_image_tag_with_folder(variant.images.first&.attachment, width: 200, crop: :fill, model: Spree::Image),
        minValue: helpers.number_to_currency(variant.price - params[:trade_in_min_value].to_f),
        maxValue: helpers.number_to_currency(variant.price - params[:trade_in_max_value].to_f)
      }
    end

    private

    def set_form_variables
      @trade_in_categories = TradeInCategory.all
      @trade_in_models = TradeInModel.all.includes(:trade_in_category)
      @taxons = Taxon.where(depth: 1)
      @accessories_taxon_id = Spree::Taxon.find_by(name: 'Accesorios').id
      @products = Spree::Product.all.includes(:variants, :master, :taxons).order(:name)
      @variants = Spree::Variant.where(is_master: false).includes(:product, [option_values: :option_type]).order(:product_id)
    end

    def trade_in_request_params
      params.require(:trade_in_request).permit(:trade_in_model_id, :variant_id, :name, :email, :phone, :shop, :comment)
    end
  end
end
