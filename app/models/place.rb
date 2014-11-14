class Place
  include Mongoid::Document

   belongs_to :user

  embeds_one :location
  field :height, type: Integer

  index({location: "2dsphere"})
  # index({location: "2dsphere", height: 1})


end
