class Event
  include Mongoid::Document
  include Mongoid::Geospatial
  field :location, type: Point

  spatial_index :location
end
