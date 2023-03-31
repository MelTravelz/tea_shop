class Api::V1::Items::SearchController < ApplicationController
  before_action :params_check

  def index
    if params[:min_price].present? && params[:max_price].present? 
      items = Item.find_items_by_price(params[:min_price], params[:max_price])
    elsif params[:min_price].present? 
      items = Item.find_items_by_price(params[:min_price], 10000000000.00) 
    elsif params[:max_price].present? 
      items = Item.find_items_by_price(0.0, params[:max_price])
    elsif params[:name].present?
      items = Item.find_items_by_term(params[:name])
    end

    render json: ItemSerializer.new(items)
  end

  private
  def params_check
    if params[:min_price].to_i < 0 || params[:max_price].to_i < 0 || (params[:name].present? && (params[:min_price].present? || params[:max_price].present?))
      render json: { "errors": [] }, status: 400
    end
  end
end