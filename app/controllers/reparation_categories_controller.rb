# frozen_string_literal:true

class ReparationCategoriesController < StoreController
  def index
    @categories = ReparationCategory.includes(photo_attachment: :blob).all
    @slider = Slider.find_by(location: :reparation)
  end
end
