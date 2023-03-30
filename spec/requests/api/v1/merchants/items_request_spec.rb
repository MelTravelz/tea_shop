require 'rails_helper'

RSpec.describe "Merchant Items API" do
  before do 
    get "/api/v1/merchants/:id/items"
  end

  describe "#index" do
    # return all items associated with a merchant
    # return a 404 if merchant is not found

  end

end