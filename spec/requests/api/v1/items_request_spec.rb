require 'rails_helper'

RSpec.describe "Items API" do
  let(:first_item) { Item.first }

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
        expect(parsed_data[:data][0][:attributes][:name]).to eq(first_item.name)
        expect(parsed_data[:data][0][:attributes][:description]).to eq(first_item.description)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to eq(first_item.unit_price)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to be_a(Float)
      end
    end
  end

  describe "#show" do
    context "when successful" do
      before do
        get "/api/v1/items/#{first_item.id}"
      end

      it "returns one item" do
        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)

        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])


        expect(parsed_data[:data][:id]).to eq(first_item.id.to_s)
        expect(parsed_data[:data][:type]).to eq('item')

        expect(parsed_data[:data][:attributes][:name]).to eq(first_item.name)
        expect(parsed_data[:data][:attributes][:description]).to eq(first_item.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to eq(first_item.unit_price)
        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(first_item.merchant_id)
      end
    end
  end
end