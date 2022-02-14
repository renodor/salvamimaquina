# frozen_string_literal:true

class Spree::FakeApiCallsController < ApplicationController
  def show_request
    @http_method = params[:http_method]
    @endpoint = params[:endpoint]
    @payload = JSON.parse(params[:payload])
    @response = JSON.parse(params[:response])
  end
end
