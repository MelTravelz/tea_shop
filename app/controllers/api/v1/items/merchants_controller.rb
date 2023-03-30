class Api::V1::Items::MerchantsController < ApplicationController
  def show
    item = Item.find(params[:id])
    merchant = Merchant.find(item.merchant_id)
    render json: MerchantSerializer.new(merchant)
  end
end