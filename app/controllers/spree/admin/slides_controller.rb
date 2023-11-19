# frozen_string_literal:true

module Spree
  module Admin
    class SlidesController < Spree::Admin::BaseController
      def new
        @slider = Slider.find(params[:slider_id])
        @slide = Slide.new
      end

      def edit
        @slider = Slider.find(params[:slider_id])
        @slide = Slide.find(params[:id])
      end

      def create
        @slider = Slider.find(params[:slider_id])
        @slide = Slide.new(slide_params)
        @slide.slider = @slider
        if @slide.save
          redirect_to edit_admin_slider_path(@slider.id)
        else
          render :new
        end
      end

      def update
        @slider = Slider.find(params[:slider_id])
        @slide = Slide.find(params[:id])
        if @slide.update(slide_params)
          redirect_to edit_admin_slider_path(@slider.id)
        else
          render :edit
        end
      end

      def destroy
        Slide.find(params[:id]).destroy
        redirect_to edit_admin_slider_path(Slider.find(params[:slider_id]))
      end

      private

      def slide_params
        params.require(:slide).permit(:link, :order, :alt, :image, :image_mobile)
      end
    end
  end
end