class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    merchant = Merchant.find(params[:item][:merchant_id])
    new_item = Item.new(item_params)
    if new_item.save
      render json: ItemSerializer.new(new_item), status: 201
    else
      render json: { errors: new_item.errors.full_messages.join(', ') }, status: :bad_request
    end
  end

  def update
    update_item = Item.find(params[:id])
    if update_item.update(item_params)
      render json: ItemSerializer.new(update_item)
    end
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  private
  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end