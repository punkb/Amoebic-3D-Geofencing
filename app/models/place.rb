class Place
  include Mongoid::Document

 

  
  field :height, type: Integer
  embeds_one :location

  index({location: "2dsphere"})
    belongs_to :user
  # index({location: "2dsphere", height: 1})


end
