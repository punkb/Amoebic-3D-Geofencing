class Location
  include Mongoid::Document

   field :type, type: String
   field :coordinates, type: Array
   

  

  embedded_in :place

  #belongs_to :user
end
