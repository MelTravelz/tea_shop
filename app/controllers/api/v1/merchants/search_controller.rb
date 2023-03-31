class Api::V1::Merchants::SearchController < ApplicationController
  def show
    merchant = Merchant.find_merchant_by_term(params[:name])
    if merchant != nil
      render json: MerchantSerializer.new(merchant)
    else
      render json: { "data": {} }
    end
  end
end