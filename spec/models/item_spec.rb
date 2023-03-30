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

end