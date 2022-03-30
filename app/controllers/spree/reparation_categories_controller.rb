# frozen_string_literal:true

module Spree
  class ReparationCategoriesController < Spree::StoreController
    def index
      @categories = ReparationCategory.includes(photo_attachment: :blob).all
      @slider = Slider.find_by(location: :reparation)
    end
  end
end
