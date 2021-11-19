# frozen_string_literal:true

module Spree
  module Admin
    class BannersController < Spree::Admin::BaseController
      def index
        @banners = Banner.all
      end

      def show
        @banner = Banner.find(params[:id])
      end

      def new
        @banner = Banner.new
      end

      def edit
        @banner = Banner.find(params[:id])
      end

      def create
        @banner = Banner.new(banner_params)
        if @banner.save
          redirect_to admin_banners_path
        else
          render :new
        end
      end

      def update
        @banner = Banner.find(params[:id])
        if @banner.update(banner_params)
          redirect_to admin_banners_path
        else
          render :edit
        end
      end

      def destroy
        Banner.find(params[:id]).destroy
        redirect_to admin_banners_path
      end

      private

      def banner_params
        params.require(:banner).permit(:location, :photo, :text_one, :text_two, :text_three)
      end
    end
  end
end
