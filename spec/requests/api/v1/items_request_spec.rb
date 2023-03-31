require 'rails_helper'

RSpec.describe "Items API", type: :request do
  before do
    create_list(:item, 5)
  end

  let(:bond) { Merchant.create(name: "James Bond", id: 700) }

  let(:item1) { Item.first }
  let(:item_to_update) { Item.second }
  let(:item_to_delete) { Item.third }
  let(:new_item) { Item.last }

  let(:item_params) {{
    "name": name,
    "description": description,
    "unit_price": unit_price,
    "merchant_id": merchant_id,
  }}

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
    let(:name) { "Turkish Cay" }
    let(:description) { "Harvested by Hemshin locals." }
    let(:unit_price) { 100.99 }
    let(:merchant_id) { bond.id }

    context "when successful" do
      it "creates a new item" do
        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: JSON.generate(item_params)

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

      it "returns a 404 error message when merchant_id is nil/invalid" do
        item_params[:merchant_id] = nil

        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: item_params, as: :json

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(404)      
        expect(parsed_data[:message]).to eq("Couldn't find Merchant without an ID")
      end

      it "returns a 404 error message when merchant_id is invalid" do
        item_params[:merchant_id] = 0

        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: item_params, as: :json

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(404)  
        expect(parsed_data[:message]).to eq("Couldn't find Merchant with 'id'=0")
      end
    end
  end

  describe "#update" do
    let(:name) { "Turkish Cay" }
    let(:description) { "Harvested by Hemshin locals." }
    let(:unit_price) { 100.99 }
    let(:merchant_id) { bond.id }
    
    context "when successful" do
      it "can update an item" do
        expect(item_to_update.name).to_not eq("Turkish Cay")
        expect(item_to_update.description).to_not eq("Harvested by Hemshin locals.")
        expect(item_to_update.unit_price).to_not eq(100.99)
        expect(item_to_update.merchant_id).to_not eq(bond.id)

        headers = {"CONTENT_TYPE" => "application/json"}
        put  "/api/v1/items/#{item_to_update.id}", headers: headers, params: item_params, as: :json
        updated_item = Item.second

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])

        expect(parsed_data[:data][:id]).to eq(updated_item.id.to_s)
        expect(parsed_data[:data][:type]).to eq('item')

        expect(parsed_data[:data][:attributes][:name]).to eq(updated_item.name)
        expect(parsed_data[:data][:attributes][:description]).to eq(updated_item.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to eq(updated_item.unit_price)

        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(updated_item.merchant_id)

        expect(parsed_data[:data][:attributes][:merchant_id]).to_not eq(item_to_update.merchant_id)
        expect(parsed_data[:data][:attributes][:name]).to_not eq(item_to_update.name)
        expect(parsed_data[:data][:attributes][:description]).to_not eq(item_to_update.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to_not eq(item_to_update.unit_price)
      end

      it "can update only one attribute of an item" do
        item_params = ({
          "name": "English Earl Grey"
        })

        expect(item_to_update.name).to_not eq("English Earl Grey")

        headers = {"CONTENT_TYPE" => "application/json"}
        put  "/api/v1/items/#{item_to_update.id}", headers: headers, params: item_params, as: :json
        updated_item = Item.second 

        expect(response).to be_successful

        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_data.size).to eq(1)
        expect(parsed_data[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed_data[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])

        expect(parsed_data[:data][:id]).to eq(updated_item.id.to_s)
        expect(parsed_data[:data][:type]).to eq('item')

        expect(parsed_data[:data][:attributes][:name]).to eq(updated_item.name)
        expect(parsed_data[:data][:attributes][:name]).to_not eq(item_to_update.name)
        
        expect(parsed_data[:data][:attributes][:description]).to eq(item_to_update.description)
        expect(parsed_data[:data][:attributes][:unit_price]).to eq(item_to_update.unit_price)
        expect(parsed_data[:data][:attributes][:merchant_id]).to eq(item_to_update.merchant_id)
      end
    end

    context "when NOT successful" do
      it "returns a 400 error message when merchant_id is nil/invalid" do
        item_params[:merchant_id] = nil

        expect(item_to_update.name).to_not eq("Turkish Cay")
        expect(item_to_update.description).to_not eq("Harvested by Hemshin locals.")
        expect(item_to_update.unit_price).to_not eq(100.99)
        expect(item_to_update.merchant_id).to_not eq(bond.id)
        
        headers = {"CONTENT_TYPE" => "application/json"}
        put  "/api/v1/items/#{item_to_update.id}", headers: headers, params: item_params, as: :json
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)      
        expect(parsed_data[:errors]).to eq("Merchant must exist")
      end

      it "returns a 404 error message when merchant_id is invalid" do
        item_params[:merchant_id] = 0

        expect(item_to_update.name).to_not eq("Turkish Cay")
        expect(item_to_update.description).to_not eq("Harvested by Hemshin locals.")
        expect(item_to_update.unit_price).to_not eq(100.99)
        expect(item_to_update.merchant_id).to_not eq(bond.id)
        
        headers = {"CONTENT_TYPE" => "application/json"}
        put  "/api/v1/items/#{item_to_update.id}", headers: headers, params: item_params, as: :json
        parsed_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)      
        expect(parsed_data[:errors]).to eq("Merchant must exist")
      end
    end
  end

  describe "destroy" do
    context "when successful" do
      it "can destroy an item" do
        expect(Item.count).to eq(5)

        delete "/api/v1/items/#{item_to_delete.id}"

        expect(Item.count).to eq(4)
        expect(response).to be_successful
        expect(response).to have_http_status(204)
      end

      it "can destory item and associated records if its single-item-invoice" do
        Item.destroy_all
        Merchant.destroy_all

        merchant = create(:merchant)

        item1 = create(:item, merchant: merchant)
        item2 = create(:item, merchant: merchant)
        item3 = create(:item, merchant: merchant)

        customer1 = create(:customer)

        invoice1 = create(:invoice, merchant: merchant, customer: customer1)
        invoice2 = create(:invoice, merchant: merchant, customer: customer1)

        create(:invoice_item, item: item1, invoice: invoice1)
        create(:invoice_item, item: item2, invoice: invoice2)
        create(:invoice_item, item: item3, invoice: invoice2)

        create(:transaction, invoice:invoice1)
        create(:transaction, invoice:invoice2)
  
        expect(Item.all.to_a).to eq([item1, item2, item3])
        expect(Invoice.all.to_a).to eq([invoice1, invoice2])
        expect(InvoiceItem.all.size).to eq(3)
        expect(Transaction.all.size).to eq(2)

        delete "/api/v1/items/#{item1.id}"

        expect(Item.all.to_a).to eq([item2, item3])
        expect(Invoice.all.to_a).to eq([invoice2])
        expect(InvoiceItem.all.size).to eq(2)
        expect(Transaction.all.size).to eq(1)  

        expect(response).to be_successful
        expect(response).to have_http_status(204)
      end
    end

    context "when NOT successful" do
      it "returns a 404 error message when merchant_id is invalid" do
        expect(Item.count).to eq(5)

        item4 = Item.fourth
        item4.id = 0

        delete "/api/v1/items/#{item4.id}"

        expect(Item.count).to eq(5)

        expect(response).to have_http_status(404) 

        parsed_data = JSON.parse(response.body, symbolize_names: true)
        
        expect(parsed_data[:message]).to eq("Couldn't find Item with 'id'=#{item4.id}")
      end
    end
  end
end