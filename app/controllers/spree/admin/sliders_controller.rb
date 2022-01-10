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
      end

      def create
        @slider = Slider.new(slider_params)
        if @slider.save
          redirect_to admin_sliders_path
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
        params.require(:slider).permit(:location, :name, :auto_play, :navigation, :pagination, :delay_between_slides, :space_between_slides, :force_slide_full_width, :image_per_slide_s, :image_per_slide_m, :image_per_slide_l, :image_per_slide_xl, slide_images: [], mobile_slide_images: [])
      end
    end
  end
end
