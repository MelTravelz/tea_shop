require 'rails_helper'

RSpec.describe "Items API" do
  let(:item1) { Item.first }

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
        expect(parsed_data[:data][0][:attributes][:name]).to eq(item1.name)
        expect(parsed_data[:data][0][:attributes][:description]).to eq(item1.description)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to eq(item1.unit_price)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to be_a(Float) # need to test?? special note in instructions for this datatype
      end
    end
  end

  describe "#show" do
    context "when successful" do
      before do
        get "/api/v1/items/#{item1.id}"
      end

      it "returns one item" do
        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)

        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])


        expect(parsed_data[:data][:id]).to eq(item1.id.to_s)
        expect(parsed_data[:data][:type]).to eq('item')

        expect(parsed_data[:data][:attributes][:name]).to eq(item1.name)
        expect(parsed_data[:data][:attributes][:description]).to eq(item1.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to eq(item1.unit_price)
        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(item1.merchant_id)
      end
    end

    context "when NOT successful" do
      it "returns an error message when incorrect ID number is sent" do
        get "/api/v1/items/0"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=0")
      end

      it "returns an error message when incorrect ID number is sent" do
        get "/api/v1/items/0"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=0")
      end

      it "returns an error message when non-integer is sent" do
        get "/api/v1/items/ABC"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=ABC")
      end
    end
  end
end