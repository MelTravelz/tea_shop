require 'rails_helper'

RSpec.describe "Merchant Items API", type: :request do
  describe "#index" do
    context "when successful" do
      it "returns all items" do
        merchant = create(:merchant)

        item1 = create(:item, merchant: merchant)
        item2 = create(:item, merchant: merchant)
        item3 = create(:item, merchant: merchant)

        get "/api/v1/merchants/#{merchant.id}/items"

        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].size).to eq(3)
        expect(parsed_data[:data]).to be_an(Array)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        
        expect(parsed_data[:data][0][:attributes][:name]).to eq(item1.name)
        expect(parsed_data[:data][1][:attributes][:name]).to eq(item2.name)
        expect(parsed_data[:data][2][:attributes][:name]).to eq(item3.name)

        expect(parsed_data[:data][0][:attributes][:description]).to eq(item1.description)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to eq(item1.unit_price)
        expect(parsed_data[:data][0][:attributes][:merchant_id]).to eq(item1.merchant_id)
      end
    end

    context "when NOT successful" do
      it "returns a 404 error message when incorrect ID number is sent" do
        get "/api/v1/merchants/0/items"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Merchant with 'id'=0")
      end

      it "returns a 404 error message when non-integer is sent" do
        get "/api/v1/merchants/ABC/items"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Merchant with 'id'=ABC")
      end
    end
  end
end