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
