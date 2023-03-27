require 'rails_helper'

RSpec.describe "Merchants API" do
  it "can GET all merchants" do
    create_list(:merchant, 3)

    get "/api/v1/merchants"
    expect(response).to be_successful
    
    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(Integer)

      expect(merchant).to have_key(:name)
      expect(merchant[:name]).to be_an(String)
    end
  end
end