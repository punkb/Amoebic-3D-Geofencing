class Event
  include Mongoid::Document
   
  field :name 
  field :location, type: Array


end
