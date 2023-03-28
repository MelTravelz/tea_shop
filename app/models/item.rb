class Item < ApplicationRecord
  validates :name, presence: true #, length: { maximum: 20 }
  validates :description, presence: true 
  validates :unit_price, presence: true, numericality: true
  validates :merchant_id, presence: true, numericality: true

  
  belongs_to :merchant
end