class PlacesController < ApplicationController
  def create

  	 @lng_lat = [params[:lng].to_f, params[:lat].to_f]
  	# @lng_lat = [-6.251898, 53.360798]
  	puts "*********@lng_lat"+"#{@lng_lat}"
  	  @alt = params[:alt]
  	 # @alt = 1
  	
    @place = Place.create(location:{type:"Point", coordinates:@lng_lat}, height:@alt)
  end

  def update
  end





end

#TO generate random points is square 
class Random
   def location(lat, lng, max_dist_meters)
      max_radius = Math.sqrt((max_dist_meters ** 2) / 2.0)
     lat_offset = rand(10 ** (Math.log10(max_radius / 1.11)-5))
         lng_offset = rand(10 ** (Math.log10(max_radius / 1.11)-5))
     lat += [1,-1].sample * lat_offset
        lng += [1,-1].sample * lng_offset
         lat = [[-90, lat].max, 90].min
         lng = [[-180, lng].max, 180].min
     [lat, lng]
       end
   end

 for i in 0..100
  coords = Random.new.location(53.360498, -6.251311, 200)
  coords = coords.reverse
  User.create(name:names[i])
  a = User.last
  a.places << Place.create(location:{ type: "Point", coordinates:coords[i] }, height:1)
  a.save
 end


def createUsers(lat, lng, dist, numberofusers, alt, names)

  for i in 0..numberofusers-1
    coords = Random.new.location(lat, lng, dist)
    coords = coords.reverse
    User.create(name:names[i])
    a = User.last
    a.places << Place.create(location:{ type: "Point", coordinates:coords }, height:alt)
    a.save

  end
  
end

53.361204, -6.250029, 100, 5, 1, names 
createUsers(53.360702, -6.251196, 250, 100, 1, names)