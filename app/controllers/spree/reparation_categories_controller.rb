# frozen_string_literal:true

module Spree
  class ReparationCategoriesController < Spree::StoreController
    def index
      @categories = ReparationCategory.all
    end
  end
end
