class Merchant < ApplicationRecord
  validates :name, presence: true

  has_many :items

  def self.find_merchant_by_term(name)
    where("name ILIKE ?", "%#{name}%")
    .order(:name)
    .first
  end
end