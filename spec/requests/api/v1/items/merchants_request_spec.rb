require 'rails_helper'

RSpec.describe "Items Merchant API" do
  describe "#show" do
    before do
      create_list(:item, 2)
    end
    let(:item1) { Item.first }
    
    context "when successful" do
      before do 
        get "/api/v1/items/#{item1.id}/merchant"
      end

      it "returns the merchant associated with an item" do
        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)
        expect(parsed_data[:data]).to be_a(Hash)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])

        expect(parsed_data[:data][:attributes].size).to eq(1)
        
        expect(parsed_data[:data][:id]).to eq(item1.merchant.id.to_s)
        expect(parsed_data[:data][:type]).to eq('merchant')
        expect(parsed_data[:data][:attributes][:name]).to eq(item1.merchant.name)
      end
    end

    context "when NOT successful" do
      it "returns a 404 error message when incorrect ID number is sent" do
        get "/api/v1/items/0/merchant"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=0")
      end

      it "returns a 404 error message when non-integer is sent" do
        get "/api/v1/items/ABC/merchant"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=ABC")
      end

      xit "returns a 404 if merchant is not found" do 
        # how to make merchant "not found" ??

        get "/api/v1/items/#{item1.id}/merchant"

        expect(response).to have_http_status(404) 

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        
        expect(parsed_data[:message]).to eq("Couldn't find Merchant with 'id'=0")
      end
    end
  end
    # let(:carmen) { Merchant.create(name: "Carmen SanDiego", id: 55) }
    # let(:chai) { Item.create(name: "Vanilla Chai", description: "So Delish!", unit_price: 99.50, merchant_id: carmen.id ) }
end