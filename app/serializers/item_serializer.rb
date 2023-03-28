class ItemSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price, :merchant_id

  # How is this working with enumerable? 
  # (does the gem change it back into a float?) 
  # attribute :unit_price do |object|
  #   object.unit_price.to_f
  # end
end
