# frozen_string_literal:true

module Spree
  module Admin
    class SlidersController < Spree::Admin::BaseController
      def index
        @sliders = Slider.all
      end

      def new
        @slider = Slider.new
      end

      def edit
        @slider = Slider.find(params[:id])
        @slider_location_url = location_url
      end

      def create
        @slider = Slider.new(slider_params)
        if @slider.save
          redirect_to new_admin_slider_slide_path(@slider.id)
        else
          render :new
        end
      end

      def update
        @slider = Slider.find(params[:id])
        if @slider.update(slider_params)
          redirect_to admin_sliders_path
        else
          render :edit
        end
      end

      def destroy
        Slider.find(params[:id]).destroy
        redirect_to admin_sliders_path
      end

      private

      def slider_params
        params.require(:slider).permit(:location, :name, :auto_play, :navigation, :pagination, :fallback_image, :delay_between_slides, :space_between_slides, :force_slide_full_width, :image_per_slide_s, :image_per_slide_m, :image_per_slide_l, :image_per_slide_xl)
      end

      def location_url
        case @slider.location
        when 'home_page'
          root_path(anchor: "#{@slider.location}-slider")
        when 'products'
          products_es_mx_path(anchor: "#{@slider.location}-slider")
        when 'trade_in'
          new_trade_in_request_path(anchor: "#{@slider.location}-slider")
        when 'reparation'
          reparation_categories_path(anchor: "#{@slider.location}-slider")
        when 'corporate_clients_1', 'corporate_clients_2'
          corporate_clients_path(anchor: "#{@slider.location}-slider")
        when 'about'
          about_path(anchor: "#{@slider.location}-slider")
        when 'contact'
          contact_path(anchor: "#{@slider.location}-slider")
        end
      end
    end
  end
end
