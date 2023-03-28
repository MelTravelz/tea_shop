class Item < ApplicationRecord
  validates :name, presence: true #, length: { maximum: 20 }
  # validates :description, presence: true  <- NOT ABSOLUTELY NECESSARY
  validates :unit_price, presence: true, numericality: true
  
  belongs_to :merchant
end