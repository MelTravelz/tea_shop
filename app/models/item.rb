class Item < ApplicationRecord
  validates :name, presence: true 
  validates :description, presence: true 
  validates :unit_price, presence: true, numericality: true

  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  def destroy_association
    invoices.each do |invoice|
      invoice.destroy if invoice.items.size == 1
    end
  end

  def self.find_items_by_term(name)
    where("name ILIKE ?", "%#{name}%")
    .order(:name)
  end

  def self.find_items_by_price(min_price, max_price)
    where("unit_price >= :min AND unit_price <= :max", { min: min_price, max: max_price })
    .order(:unit_price)
  end
end