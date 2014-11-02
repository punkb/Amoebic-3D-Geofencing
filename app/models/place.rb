class Place
  include Mongoid::Document
  include Mongoid::Geospatial

  field :location, type: Point

  belongs_to :user

  spatial_index :location



end
