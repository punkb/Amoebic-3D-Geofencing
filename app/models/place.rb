class Place
  include Mongoid::Document
  # include Mongoid::Geospatial
  

  # field :location, type: Point

   # belongs_to :user

  # spatial_index :location

   belongs_to :user

  embeds_one :location

  index({location: "2dsphere"})


end
