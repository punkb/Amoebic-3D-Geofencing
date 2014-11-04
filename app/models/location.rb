class Location
  include Mongoid::Document

   field :type, type: String
  field :coordinates, type: Array

  #index({coordinates: "2dsphere"})

  embedded_in :place

  #belongs_to :user
end
