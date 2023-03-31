require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
    it { should validate_numericality_of :unit_price }
  end 

  describe "relationships" do
    it { should belong_to :merchant } 
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe "instance methods" do
    before do
      @merchant = create(:merchant)

      @item1 = create(:item, merchant: @merchant)
      @item2 = create(:item, merchant: @merchant)
      @item3 = create(:item, merchant: @merchant)

      @customer1 = create(:customer)

      @invoice1 = create(:invoice, merchant: @merchant, customer: @customer1)
      @invoice2 = create(:invoice, merchant: @merchant, customer: @customer1)

      create(:invoice_item, item: @item1, invoice: @invoice1)
      create(:invoice_item, item: @item2, invoice: @invoice2)
      create(:invoice_item, item: @item3, invoice: @invoice2)

      create(:transaction, invoice:@invoice1)
      create(:transaction, invoice:@invoice2)
    end

    it "#destroy_association" do
      expect(Invoice.all.to_a).to eq([@invoice1, @invoice2])
      expect(InvoiceItem.all.size).to eq(3)
      expect(Transaction.all.size).to eq(2)

      @item1.destroy_association

      expect(Invoice.all.to_a).to eq([@invoice2])
      expect(InvoiceItem.all.size).to eq(2)
      expect(Transaction.all.size).to eq(1)
    end
  end

  describe "class methods" do
    before do
      merchant = create(:merchant)

      @honey = create(:item, merchant: merchant, name: "Honey Vanilla", unit_price: 5.00)
      @sleepy_mint = create(:item, merchant: merchant, name: "Sleepytime Mint", unit_price: 8.55)
      @sleepy_relaxy = create(:item, merchant: merchant, name: "Sleepy Relaxy", unit_price: 10.00)
      @tension_tamer = create(:item, merchant: merchant, name: "Tension Tamer", unit_price: 12.35)
      @sleepy = create(:item, merchant: merchant, name: "Sleepytime", unit_price: 3.25)
    end

    describe "::find_items_by_term" do
      it "returns case-insensitive, alphabetical matches when search term is found" do
        expect(Item.find_items_by_term("slEEpy")).to eq([@sleepy_relaxy, @sleepy, @sleepy_mint])
        
        expect(Item.find_items_by_term("slEEpy")).to_not eq([@honey, @sleepy_relaxy, @sleepy, @sleepy_mint, @tension_tamer])
      end

      it "returns [] when search term is NOT found" do
        expect(Item.find_items_by_term("xyz")).to eq([])
      end
    end

    describe "::find_items_by_price" do
      it "returns only items BETWEEN min/max price" do
        expect(Item.find_items_by_price(5.00, 10.00)).to eq([@honey, @sleepy_mint, @sleepy_relaxy])

        expect(Item.find_items_by_price(0, 5.00)).to eq([@sleepy, @honey])

        expect(Item.find_items_by_price(10.00, 100.00)).to eq([@sleepy_relaxy, @tension_tamer])
      end

      it "returns [] when min_price is so big NO item it found" do
        expect(Item.find_items_by_price(20.00, 50.00)).to eq([])
      end
    end
  end
end