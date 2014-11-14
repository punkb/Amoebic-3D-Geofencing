class PlacesController < ApplicationController
  def create

  	@lng_lat = [params[:lng], params[:lat]]
  	@alt = params[:alt]
  	
    @place = Place.create(location:{type:"Point", coordinates:@lng_lat, height:@alt})
  end

  def update
  end
end
