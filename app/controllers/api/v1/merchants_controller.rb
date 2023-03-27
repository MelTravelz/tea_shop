class Api::V1::MerchantsController < ApplicationController
  def index
    render json: Merchant.all
    # merchants = Merchant.all
    # render json: MerchantSerializer.format_merchants(merchants)
  end
end