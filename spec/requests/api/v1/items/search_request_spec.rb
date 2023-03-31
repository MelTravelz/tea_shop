require 'rails_helper'

RSpec.describe "Items Search API", type: :request do
  describe "#index" do
    before do
      merchant = create(:merchant)

      @sleepy = create(:item, merchant: merchant, name: "Sleepytime", unit_price: 3.25)
      @honey = create(:item, merchant: merchant, name: "Honey Vanilla", unit_price: 5.00)
      @sleepy_mint = create(:item, merchant: merchant, name: "Sleepytime Mint", unit_price: 8.55)
      @sleepy_relaxy = create(:item, merchant: merchant, name: "Sleepy Relaxy", unit_price: 10.00)
      @tension_tamer = create(:item, merchant: merchant, name: "Tension Tamer", unit_price: 12.35)
    end

    context "when successful" do
      it "returns all (case insensitive) items that match a search term" do        
        get "/api/v1/items/find_all?name=sleepy"

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].size).to eq(3)
        expect(parsed_data[:data]).to be_an(Array)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        
        expect(parsed_data[:data][0][:attributes][:name]).to eq(@sleepy_relaxy.name)
        expect(parsed_data[:data][1][:attributes][:name]).to eq(@sleepy.name)
        expect(parsed_data[:data][2][:attributes][:name]).to eq(@sleepy_mint.name)
      end

      it "returns all items greater than or equal to a MIN price" do
        get "/api/v1/items/find_all?min_price=10.00"

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].size).to eq(2)
        expect(parsed_data[:data]).to be_an(Array)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        
        expect(parsed_data[:data][0][:attributes][:name]).to eq(@sleepy_relaxy.name)
        expect(parsed_data[:data][1][:attributes][:name]).to eq(@tension_tamer.name)

        expect(parsed_data[:data][0][:attributes][:description]).to eq(@sleepy_relaxy.description)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to eq(@sleepy_relaxy.unit_price)
        expect(parsed_data[:data][0][:attributes][:merchant_id]).to eq(@sleepy_relaxy.merchant_id)
      end

      it "returns all items less than or equal to a MAX price" do       
        get "/api/v1/items/find_all?max_price=10.00"

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].size).to eq(4)
        expect(parsed_data[:data]).to be_an(Array)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        
        expect(parsed_data[:data][0][:attributes][:name]).to eq(@sleepy.name)
        expect(parsed_data[:data][1][:attributes][:name]).to eq(@honey.name)
        expect(parsed_data[:data][2][:attributes][:name]).to eq(@sleepy_mint.name)
        expect(parsed_data[:data][3][:attributes][:name]).to eq(@sleepy_relaxy.name)

        expect(parsed_data[:data][0][:attributes][:description]).to eq(@sleepy.description)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to eq(@sleepy.unit_price)
        expect(parsed_data[:data][0][:attributes][:merchant_id]).to eq(@sleepy.merchant_id)
      end

      it "returns all items BETWEEN a given min & max price" do       
        get "/api/v1/items/find_all?min_price=5.00&max_price=10.00"

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].size).to eq(3)
        expect(parsed_data[:data]).to be_an(Array)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        
        expect(parsed_data[:data][0][:attributes][:name]).to eq(@honey.name)
        expect(parsed_data[:data][1][:attributes][:name]).to eq(@sleepy_mint.name)
        expect(parsed_data[:data][2][:attributes][:name]).to eq(@sleepy_relaxy.name)

        expect(parsed_data[:data][0][:attributes][:description]).to eq(@honey.description)
        expect(parsed_data[:data][0][:attributes][:unit_price]).to eq(@honey.unit_price)
        expect(parsed_data[:data][0][:attributes][:merchant_id]).to eq(@honey.merchant_id)
      end
      
      it "returns 200 when min_price is so big there are no matches" do
        get "/api/v1/items/find_all?min_price=20.00"

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data).to be_a(Hash)
        expect(parsed_data.keys).to eq([:data])
        expect(parsed_data[:data]).to eq([])
      end
    end

    context "when NOT successful" do
      context "when name & min/max are sent" do
        it "returns 404 error when name & min or max price is sent" do
          get "/api/v1/items/find_all?min_price=5.00&max_price=10.00&name=sleepy"

          expect(response).to have_http_status(400)

          parsed_data = JSON.parse(response.body, symbolize_names: true)

          expect(parsed_data[:errors]).to eq([])
        end
      end

      context "when search term is invalid" do
        it "returns a 200 status if search term finds no matches" do
          get "/api/v1/items/find_all?name=xyz"

          expect(response).to be_successful
          
          parsed_data = JSON.parse(response.body, symbolize_names: true)

          expect(parsed_data).to be_a(Hash)
          expect(parsed_data.keys).to eq([:data])
          expect(parsed_data[:data]).to eq([])
        end
      end

      context "when max/min price is invalid" do
        it "returns 400 error message when min_price is less than 0" do
          get  "/api/v1/items/find_all?min_price=-5"

          expect(response).to have_http_status(400)
          
          parsed_data = JSON.parse(response.body, symbolize_names: true)

          expect(parsed_data[:errors]).to eq([])
        end

        it "returns 400 error message when max_price is less than 0" do
          get  "/api/v1/items/find_all?max_price=-5"

          expect(response).to have_http_status(400)
          
          parsed_data = JSON.parse(response.body, symbolize_names: true)

          expect(parsed_data[:errors]).to eq([])
        end
      end
    end
  end
end