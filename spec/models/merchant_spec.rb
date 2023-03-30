require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
  end 
  
  describe "relationships" do
    it { should have_many :items }
  end

  describe "class methods" do
    before do
      @scarlet = create(:merchant, name: "Scarlet Raleigh")
      @oscar = create(:merchant, name: "Oscar Wild")
      @carmen = create(:merchant, name: "Carmen SanDiego")
      @planet = create(:merchant, name: "Captain Planet")
    end

    describe "::find_merchant_by_term" do
      it "returns first, alphabetical match when search term is found" do
      expect(Merchant.find_merchant_by_term("car")).to eq(@carmen)

      expect(Merchant.find_merchant_by_term("car")).to_not eq(@scarlet)
      expect(Merchant.find_merchant_by_term("car")).to_not eq(@oscar)
      expect(Merchant.find_merchant_by_term("car")).to_not eq(@planet)
      end

      it "is case insensitive" do
        expect(Merchant.find_merchant_by_term("Car")).to eq(@carmen)
  
        expect(Merchant.find_merchant_by_term("car")).to_not eq(@scarlet)
        expect(Merchant.find_merchant_by_term("car")).to_not eq(@oscar)
        expect(Merchant.find_merchant_by_term("car")).to_not eq(@planet)
        end

      it "returns nil when search term is NOT found" do
        expect(Merchant.find_merchant_by_term("xyz")).to eq(nil)
      end
    end
  end
end