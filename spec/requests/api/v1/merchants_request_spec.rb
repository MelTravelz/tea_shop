require 'rails_helper'

RSpec.describe "Merchants API" do
  before do
    create_list(:merchant, 3)
  end

  describe "#index" do
    before do
      get "/api/v1/merchants"
    end

    context "when successful" do
      it "returns all merchants" do
        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:data].count).to eq(3)
        expect(parsed_data[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][0][:attributes][:name]).to eq(Merchant.first.name)
      end
    end

    # context "when NOT successful" do
    #   it "returns an error message" do
    #     expect(response).to have_http_status(404)
    #   end
    # end
  end
end