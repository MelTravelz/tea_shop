require 'rails_helper'

RSpec.describe "Merchants API" do
  before do
    create_list(:merchant, 4)
  end

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
        expect(parsed_data[:data][0][:attributes][:name]).to eq(Merchant.first.name)
      end
    end
  end

  describe "#index" do
    context "when successful" do
      before do
        get "/api/v1/merchants/#{Merchant.first.id}"
      end

      it "returns one merchant" do
        expect(response).to be_successful
        # # expect(response).to have_http_status(:success)
        # expect(response).to have_http_status(200)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_data[:data].size).to eq(3)

        expect(parsed_data[:data][:attributes].size).to eq(1)

        expect(parsed_data[:data][:id]).to eq(Merchant.first.id.to_s)
        expect(parsed_data[:data][:type]).to eq('merchant')
        expect(parsed_data[:data][:attributes][:name]).to eq(Merchant.first.name)
      end
    end

    context "when NOT successful" do
      before do
        get "/api/v1/merchants/ABC"
      end

      it "returns an error message" do
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Merchant with 'id'=ABC")
      end
    end
  end
end