require 'rails_helper'

RSpec.describe "Merchants API" do
  before do
    create_list(:merchant, 4)
  end
  
  let(:merchant1) { Merchant.first }

  describe "#index" do
    before do
      get "/api/v1/merchants"
    end

    context "when successful" do
      it "returns all merchants" do
        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].size).to eq(4)
        expect(parsed_data[:data]).to be_an(Array)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][0][:attributes][:name]).to eq(merchant1.name)
      end
    end
  end

  describe "#show" do
    context "when successful" do
      before do
        get "/api/v1/merchants/#{merchant1.id}"
      end

      it "returns one merchant" do
        expect(response).to be_successful
        # # expect(response).to have_http_status(:success)
        # expect(response).to have_http_status(200)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        # expect(parsed_data[:data].size).to eq(3) <- tests the wrong data (counts keys??)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])

        expect(parsed_data[:data][:attributes].size).to eq(1)

        expect(parsed_data[:data][:id]).to eq(merchant1.id.to_s)
        expect(parsed_data[:data][:type]).to eq('merchant')
        expect(parsed_data[:data][:attributes][:name]).to eq(merchant1.name)
      end
    end

    context "when NOT successful" do
      it "returns an error message when incorrect ID number is sent" do
        get "/api/v1/merchants/0"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Merchant with 'id'=0")
      end

      it "returns an error message when non-integer is sent" do
        get "/api/v1/merchants/ABC"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Merchant with 'id'=ABC")
      end
    end
  end
end