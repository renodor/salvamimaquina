# frozen_string_literal: true

module Spree
  module Frontend
    class LineItemsController < ApplicationController
      def destroy
        @order = Spree::Order.find(params[:order_id])
        @line_item = @order.line_items.detect { |line_item| line_item.id == params[:id].to_i } || raise(ActiveRecord::RecordNotFound)
        @order.contents.remove_line_item(@line_item)
        redirect_to cart_path
      end
    end
  end
end
