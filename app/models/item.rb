class Item < ApplicationRecord
  validates :name, presence: true #, length: { maximum: 20 }
  validates :description, presence: true 
  validates :unit_price, presence: true, numericality: true

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
end