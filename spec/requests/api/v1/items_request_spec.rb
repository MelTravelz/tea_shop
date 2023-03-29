require 'rails_helper'

RSpec.describe "Items API" do
  before do
    create_list(:item, 5)
  end
  let(:item1) { Item.first }
  let(:item_to_update) { Item.second }
  let(:item_to_delete) { Item.third }

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
        expect(parsed_data[:data][0][:attributes][:unit_price]).to be_a(Float)
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
      it "returns a 404 error message when incorrect ID number is sent" do
        get "/api/v1/items/0"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=0")
      end

      it "returns an error message when non-integer ID is sent" do
        get "/api/v1/items/ABC"

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=ABC")
      end
    end
  end

  describe "#create"do
    let(:bond) { Merchant.create(name: "James Bond", id: 700) }
    let(:new_item) { Item.last }
    let(:name) { "Turkish Cay" }
    let(:description) { "Harvested by Hemshin locals." }
    let(:unit_price) { 100.99 }

    let(:item_params) {{
      "name": name,
      "description": description,
      "unit_price": unit_price,
      "merchant_id": bond.id,
    }}

    context "when successful" do
      it "creates a new item" do
        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: item_params, as: :json # makes: {"name"=>nil, "description"=>nil, "unit_price"=>nil, "merchant_id"=>700, "controller"=>"api/v1/items", "action"=>"create", "item"=>{"name"=>nil, "description"=>nil, "unit_price"=>nil, "merchant_id"=>700}}
        # NOTE: <JSON.generate(item: item_params)> does NOT work here, makes this: {"item"=>{"name"=>nil, "description"=>nil, "unit_price"=>nil, "merchant_id"=>700}, "controller"=>"api/v1/items", "action"=>"create"} 

        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])

        expect(parsed_data[:data][:id]).to eq(new_item.id.to_s)
        expect(parsed_data[:data][:type]).to eq('item')

        expect(parsed_data[:data][:attributes][:name]).to eq(new_item.name)
        expect(parsed_data[:data][:attributes][:description]).to eq(new_item.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to eq(new_item.unit_price)
        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(new_item.merchant_id)
      end

      it "ignores unallowable attributes & still creates a new item" do
        item_params[:tea_field] = "Karadeniz"

        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: item_params, as: :json

        expect(response).to be_successful
        
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        expect(parsed_data[:data][:attributes].keys).to_not eq([:name, :description, :unit_price, :merchant_id, :tea_field])
      end
    end

    context "when NOT successful" do
      let(:new_item) { Item.last }
      let(:name) { nil }
      let(:unit_price) { nil }
      let(:description) { nil }

      it "returns a 400 error message when any attribute is nil or inccorect data type is sent" do  
        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: item_params, as: :json

        parsed_data = JSON.parse(response.body, symbolize_names: true)       
        expect(response).to have_http_status(400)
        expect(parsed_data[:errors]).to eq("Name can't be blank, Description can't be blank, Unit price can't be blank, Unit price is not a number")
      end

      it "returns a 404 error message when merchant_id is nil" do
        item_params[:merchant_id] = nil

        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: item_params, as: :json

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(404)      
        expect(parsed_data[:message]).to eq("Couldn't find Merchant without an ID")
      end
    end
  end

  describe "#update" do
    context "when successful" do
      before do
        @item_params = ({
            "name": "English Earl Grey Tea",
            "description": "From England, or something like that.",
            "unit_price": 99.01,
            "merchant_id": item_to_update.merchant_id
        })
        @headers = {"CONTENT_TYPE" => "application/json"}
      end 

      it "can update an item" do
        expect(item_to_update.name).to_not eq("English Earl Grey Tea")
        expect(item_to_update.description).to_not eq("From England, or something like that.")
        expect(item_to_update.unit_price).to_not eq(99.01)

        put  "/api/v1/items/#{item_to_update.id}", headers: @headers, params: @item_params, as: :json
        @updated_item = Item.second # this was the item chose to update so we call it again here after the update

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])

        expect(parsed_data[:data][:id]).to eq(@updated_item.id.to_s)
        expect(parsed_data[:data][:type]).to eq('item')

        expect(parsed_data[:data][:attributes][:name]).to eq(@updated_item.name)
        expect(parsed_data[:data][:attributes][:description]).to eq(@updated_item.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to eq(@updated_item.unit_price)

        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(@updated_item.merchant_id)
        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(item_to_update.merchant_id)

        expect(parsed_data[:data][:attributes][:name]).to_not eq(item_to_update.name)
        expect(parsed_data[:data][:attributes][:description]).to_not eq(item_to_update.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to_not eq(item_to_update.unit_price)
      end
    end

    context "when NOT successful" do
      # edge case, bad merchant id returns 400 or 404 
      # sad path, bad integer id returns 404

      # it "returns a 404 error message when non-integer ID is sent" do
      # edge case, string id returns 404
    # end
    end
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

    context "when NOT successful" do
      # sad path where attribute types are not correct
      # edge case where all attributes are missing
    end
  end
end