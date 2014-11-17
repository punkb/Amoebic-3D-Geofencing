class Event
  include Mongoid::Document
  include Geocoder::Model::Mongoid
   
  field :name
  field :address 
  field :location, type: Array

  geocoded_by :address
  after_validation :geocode

  reverse_geocoded_by :coordinates
  after_validation :reverse_geocode  # auto-fetch address


end
