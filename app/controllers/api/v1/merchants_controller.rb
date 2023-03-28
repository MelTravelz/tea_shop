class Api::V1::MerchantsController < ApplicationController
  def index
    # render json: Merchant.all
    # merchants = Merchant.all
    render json: MerchantSerializer.new(Merchant.all)
    
  end
end