# frozen_string_literal:true

module Spree
  module Admin
    class ReparationCategoriesController < Spree::Admin::BaseController
      def index
        @categories = ReparationCategory.all
      end

      def new
        @category = ReparationCategory.new
      end

      def create
        cleaned_params = reparation_category_params
        cleaned_params[:products].reject!(&:blank?)
        cleaned_params[:damages].reject!(&:blank?)
        @category = ReparationCategory.new(cleaned_params)
        if @category.save
          redirect_to admin_reparation_categories_path
        else
          render :new
        end
      end

      def edit
        @category = ReparationCategory.find(params[:id])
      end

      def update
        @category = ReparationCategory.find(params[:id])
        cleaned_params = reparation_category_params
        cleaned_params[:products].reject!(&:blank?)
        cleaned_params[:damages].reject!(&:blank?)
        if @category.update(cleaned_params)
          redirect_to admin_reparation_categories_path
        else
          render :edit
        end
      end

      def destroy
        ReparationCategory.find(params[:id]).destroy
        redirect_to admin_reparation_categories_path
      end

      private

      def reparation_category_params
        params.require(:reparation_category).permit(:name, :photo, products: [], damages: [])
      end
    end
  end
end
