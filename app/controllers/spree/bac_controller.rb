# frozen_string_literal:true

class Spree::BacController < ApplicationController
  skip_before_action :verify_authenticity_token

  def bac_checkout
  end
end
