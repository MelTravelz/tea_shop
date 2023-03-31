require 'rails_helper'

RSpec.describe "Merchants Search API", type: :request do
  describe "#show" do
    before do
      @scarlet = create(:merchant, name: "Scarlet Raleigh")
      @oscar = create(:merchant, name: "Oscar Wild")
      @carmen = create(:merchant, name: "Carmen SanDiego")
      @planet = create(:merchant, name: "Captain Planet")
    end

    context "when successful" do
      it "returns the first (case insensitive) merchant that matches a search term" do
        get "/api/v1/merchants/find?name=car"
        
        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        
        expect(parsed_data.size).to eq(1)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][:attributes].size).to eq(1)

        expect(parsed_data[:data][:id]).to eq(@carmen.id.to_s)
        expect(parsed_data[:data][:type]).to eq('merchant')
        expect(parsed_data[:data][:attributes][:name]).to eq(@carmen.name)

        expect(parsed_data[:data][:attributes][:name]).to_not eq(@scarlet.name)
        expect(parsed_data[:data][:attributes][:name]).to_not eq(@oscar.name)
        expect(parsed_data[:data][:attributes][:name]).to_not eq(@planet.name)
      end
    end

    context "when NOT successful" do
      it "returns a 200 status if search term finds no matches" do
        get "/api/v1/merchants/find?name=xyz"

        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data).to be_a(Hash)
        expect(parsed_data.keys).to eq([:data])
        expect(parsed_data[:data]).to eq({})
      end
    end
  end
end