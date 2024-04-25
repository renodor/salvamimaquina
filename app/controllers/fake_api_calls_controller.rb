# frozen_string_literal:true

class FakeApiCallsController < ApplicationController
  layout 'empty'

  def show_request
    @http_method = params[:http_method]
    @endpoint = params[:endpoint]
    @payload = JSON.parse(params[:payload])
    @response = JSON.parse(params[:response])
  end
end
