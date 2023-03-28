class ItemSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price, :merchant_id

  # How is this working? 
  # attribute :unit_price do |object|
  #   object.unit_price.to_f
  # end
end
