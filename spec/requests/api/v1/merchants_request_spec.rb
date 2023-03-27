require 'rails_helper'

RSpec.describe "Merchants API" do
  it "can GET all merchants" do
    create_list(:merchant, 3)

    get "/api/v1/merchants"

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

  end
end