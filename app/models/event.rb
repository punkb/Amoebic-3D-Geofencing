class Event
  include Mongoid::Document
  include Geocoder::Model::Mongoid
  field :name, type: String
  field :address, type: String
  field :coordinates, type: Array


  geocoded_by :address
  after_validation :geocode

  reverse_geocoded_by :coordinates
  after_validation :reverse_geocode
  index({coordinates: "2dsphere"})
end
