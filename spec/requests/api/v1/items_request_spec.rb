require 'rails_helper'

RSpec.describe "Items API" do
  before do
    create_list(:item, 5)
  end
  let(:item1) { Item.first }
  let(:item_to_delete) { Item.second }

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
        expect(parsed_data[:data][0][:attributes][:merchant_id]).to eq(item1.merchant_id)
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

  describe "#create"do
    before do
      @bond = Merchant.create(name: "James Bond", id: 700)
    end

    context "when successful" do
      before do
        item_params = ({
            "name": "Turkish Cay",
            "description": "From Karadeniz region, harvested my Hemshin locals.",
            "unit_price": 100.99,
            "merchant_id": @bond.id
        })

        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

        @new_item = Item.last
      end

      # let(:new_item) { Item.last }

      it "creates a new item" do
        expect(response).to be_successful
        # expect(response).to have_http_status(201) # Is this needed?
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)

        expect(parsed_data[:data].size).to eq(3)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])

        expect(parsed_data[:data][:attributes].size).to eq(4)
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])

        expect(parsed_data[:data][:id]).to eq(@new_item.id.to_s)
        expect(parsed_data[:data][:type]).to eq('item')

        expect(parsed_data[:data][:attributes][:name]).to eq(@new_item.name)
        expect(parsed_data[:data][:attributes][:description]).to eq(@new_item.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to eq(@new_item.unit_price)
        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(@new_item.merchant_id)
      end
    end

    context "when NOT successful" do
      before do
        @item_nil_name = ({
            "name": nil,
            "description": "It's tea!",
            "unit_price": 100.99,
            "merchant_id": @bond.id
        })
        @item_nil_desc = ({
          "name": "Cay",
          "description": nil,
          "unit_price": 100.99,
          "merchant_id": @bond.id
        })
        @item_nil_price = ({
          "name": "Cay",
          "description": "It's tea!",
          "unit_price": nil,
          "merchant_id": @bond.id
        })
        @item_nil_merch = ({
          "name": "Cay",
          "description": "It's tea!",
          "unit_price": 100.99,
          "merchant_id": nil
        })

        @item_non_num_price = ({
          "name": "Cay",
          "description": "It's tea!",
          "unit_price": "ABC", # <- This should be a float/integer
          "merchant_id": @bond.id
        })
        @item_non_num_merch = ({
          "name": "Cay",
          "description": "It's tea!",
          "unit_price": 100.99,
          "merchant_id": "ABC" # <- This should be a float/integer
        })

        @item_missing_attr = ({
          "description": "It's tea!",
          "unit_price": 100.99,
          "merchant_id": @bond.id
        })

        @headers = {"CONTENT_TYPE" => "application/json"}
      end
      
      xit "returns an error message when name is missing" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_nil_name)
        
        expect(response).to have_http_status(404)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        # expect(parsed_data[:message]).to eq("??? whats the message ???")
        # NOTE: After it comes back from create action it's now unit_price = 0.0 ????
        # "{\"data\":{\"id\":null,\"type\":\"item\",\"attributes\":{\"name\":\"It's Cay\",\"description\":\"It's tea!\",\"unit_price\":0.0,\"merchant_id\":7}}}"
      end

      xit "returns an error message when description is missing" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_nil_desc)
        
        expect(response).to have_http_status(404)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        # expect(parsed_data[:message]).to eq("??? whats the message ???")
      end

      xit "returns an error message when unit_price is missing" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_nil_price)
        
        expect(response).to have_http_status(404)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        # expect(parsed_data[:message]).to eq("??? whats the message ???")
      end

      xit "returns an error message when merchant_id is missing" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_nil_merch)
        
        expect(response).to have_http_status(404)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        # expect(parsed_data[:message]).to eq("??? whats the message ???")
      end

      xit "returns an error message when unit_price is NOT a number" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_non_num_price)
        
        expect(response).to have_http_status(404)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        # expect(parsed_data[:message]).to eq("??? whats the message ???")
      end

      xit "returns an error message when merchant_id is NOT a number" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_non_num_merch)
        
        expect(response).to have_http_status(404)

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        # expect(parsed_data[:message]).to eq("??? whats the message ???")
      end

      it "returns an error message when an attribute is missing" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_missing_attr)
        expect(response).to have_http_status(400)
        # require 'pry'; binding.pry

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_data[:message]).to eq("Validation failed: Name can't be blank")
      end
    end
    # // TODO: sad path where attribute types are not correct
    # // TODO: edge case where all attributes are missing
  end

  describe "destroy" do
    context "when successful" do
      it "can destroy an item" do
       # This is an alternative to the current test: 
        # expect{ delete "/api/v1/items/#{item1.id}" }.to change(Item, :count).by(-1)

        expect(Item.count).to eq(5)

        delete "/api/v1/items/#{item_to_delete.id}"

        expect(response).to be_successful
        expect(Item.count).to eq(4)
        expect{ Item.find(item_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect{ Item.find(item_to_delete.id) }.to raise_error("Couldn't find Item with 'id'=#{item_to_delete.id}")
        
        ########### Testing the deleted object: 
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data[:id]).to eq(item_to_delete.id)
        expect(parsed_data[:name]).to eq(item_to_delete.name)
        expect(parsed_data[:description]).to eq(item_to_delete.description)
        expect(parsed_data[:unit_price]).to eq(item_to_delete.unit_price)
        expect(parsed_data[:merchant_id]).to eq(item_to_delete.merchant_id)
      end
    end
  end
end