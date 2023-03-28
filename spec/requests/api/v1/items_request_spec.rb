require 'rails_helper'

RSpec.describe "Items API" do
  before do
    create_list(:item, 5)
  end

  describe "#index" do
    before do
      get "/api/v1/items"
    end

    context "when successful" do
      it "returns all items" do
        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].size).to eq(5)
        expect(parsed_data[:data]).to be_an(Array)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])

        expect(parsed_data[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        expect(parsed_data[:data][0][:attributes][:name]).to eq(Item.first.name)
        expect(parsed_data[:data][0][:attributes][:description]).to eq(Item.first.description)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to eq(Item.first.unit_price)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to be_a(Float)
      end
    end
  end
end