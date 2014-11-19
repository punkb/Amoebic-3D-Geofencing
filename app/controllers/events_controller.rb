class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @bsonPresent = Array.new
    @heightPresent = Array.new
     @boundary = Array.new
     @present = Array.new

    @eventName = @event.name
    @eventCoordinates = @event.coordinates
    # @eventCoordinates = [-6.251208, 53.360912]
    @fixDist = 10/6378139.266
    @distance = 10/6378139.266
    @distInMeter = 5


    def search(coordinates, distance )

      #pushing coordinates parameter to check array    
      @check = Array.new
      @check << coordinates

      #Querying MongoDB to search users near coordinates: @searchResult will be an array of BSON docs.
      @searchResult = Place.geo_near(coordinates).spherical.max_distance(distance)

      #extracting coordinates from Result to compare it with @present Users as well as empty set
      @resultCoords = @searchResult.map { |e| e.location.coordinates  }
    
      #Check for uniq cordinates / remove perameter coordinates from result set for uniqness
      #CheckEmpty will be an array of uniq(new) coordinates  
      checkEmpty = @resultCoords - @check
     
        #Checking if there are minimum two new elements  
        if checkEmpty.empty? || (checkEmpty-@present).length < 2 
          puts "*********SEARCH RESULT IS EMPTY********"
          #if search search result is empty or only one new element. 
          #Then increaser the distance by 5 meters till 100meter and search again
            if distance <= 100/6378139.266
              distance = (distance+@fixDist)
              @distInMeter += 5

                puts "******* Now Searching for distance: "+"#{@distInMeter}"+"meters"
                search(coordinates, distance)
            
            end
          
        else
          puts "******"+" #{checkEmpty.length} "+"Users found withing distance = "+"#{@distInMeter}"+"meters"+"*********"
          @distInMeter = 5

          #Pushing all BSON data from SearchResult to @bsonPresent
          @searchResult.map { |e| @bsonPresent << e  }
           @bsonPresent = @bsonPresent.uniq

           #Pushing altitude of present users to @heighPresent
          @bsonPresent.map { |e| @heightPresent << e.height  }
         
          return @searchResult
        end
          @distInMeter = 5
    end

    def first_userSet(coordinates, distance)
 
      search(coordinates, distance)

      if (@searchResult).empty?
        #do Nothing
        @message = "No Users present in the stadium yet"
      else
        @neighbours_coord =  Array.new
        @neighbours_coord = @searchResult.map { |c| c.location.coordinates}
        @present = @neighbours_coord
        # @finalPolygon = @neighbours_coord
      end
    end

    first_userSet(@eventCoordinates, @distance)

    def search_neighbour_rec(coordinates, distance)

      @next_neighbours = Array.new()

      for i in 0..(coordinates.length-1)

        current_neighbours = Array.new()

        #getting ith user as current user to query for his neighbours
        @current_user = coordinates[i]

        search(@current_user, distance)
        #find uniq/new BSON doc
        # @uniqBSON = @searchResult - @bsonPresent
        current_neighbours = @searchResult.map { |c| c.location.coordinates }

         #find Uniq/new coordinates
        @uniqCoords = current_neighbours - @present
        

        if @uniqCoords.empty?
          #do Something
           @boundary << @current_user
        else

          @uniqCoords.each do |u|
            @present << u 
            @next_neighbours << u
          end 
        end #if loop ends

      #for loop Ends
      end

      if @next_neighbours.empty?
        #do something No More coords to search
      else
        #search neighbours for next_neihbours
        search_neighbour_rec(@next_neighbours, @distance)
        
      end
    #search_rec method ends  
    end

    search_neighbour_rec(@present, @distance)


    @heightPresent = @heightPresent.uniq.sort

     puts "@HEIGHT ARRAY" + "#{@heightPresent}"

    @maxHeight = @heightPresent.max
    @minHeight = @heightPresent.min

    @bsonPresentHash = @bsonPresent.map { | place, user_id, height| {lat: place.location.coordinates[1], 
                                                                      lng: place.location.coordinates[0],
                                                                      alt: place.height}}

    #group bsonPresentHash by altitude(height)
    @groupedArray = @bsonPresentHash.group_by{|x| x[:alt]}.values

    # puts "@groupedArray: "+"#{@groupedArray}"
    
  

    @temp = Array.new
    @allPointsArray = Array.new()

    for i in 0..(@heightPresent.length-1)
      @temp[i] = @groupedArray[i]

      @temp[i] << @temp[i].first

      @allPointsArray << @temp[i].map { |e| (e.tap {|hs| hs.delete(:alt)}).values.reverse }
      @allPointsArray = @allPointsArray.reverse
    end

   
def within(polygon)
  @output = Place.where({
  "location" =>{       
      "$geoWithin" => {
        "$polygon" => polygon
         
    
  }}})

  @output = @output.map { |e| e.location.coordinates }


end
   

       
      

      def convex_hull(points)
        points.sort!.uniq!
        return points if points.length < 3
          def cross(o, a, b)
            (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
          end
        @lower = Array.new
        points.each{|p|
          while @lower.length > 1 and cross(@lower[-2], @lower[-1], p) <= 0 do @lower.pop end
            @lower.push(p)
            }
        @upper = Array.new
          points.reverse_each{|p|
            while @upper.length > 1 and cross(@upper[-2], @upper[-1], p) <= 0 do @upper.pop end
            @upper.push(p)
          }
        @lower_upper = @lower[0...-1] + @upper[0...-1]
        
        
 
        return @lower_upper

        
      end

      @polygons = Array.new
       @rejectedUsers = Array.new

      for i in 0..@allPointsArray.length-1  

        convex_hull(@allPointsArray[i])

        if i > 0

          within(@t)
            
          if (@allPointsArray[i].uniq - @output.uniq).empty?
          else
            @rejectedUsers << (@allPointsArray[i].uniq - @output.uniq)
            @allPointsArray[i] = @allPointsArray[i] - (@allPointsArray[i].uniq - @output.uniq)
            convex_hull(@allPointsArray[i])
          end

        end

         @t = @lower_upper

        @convexHash = @lower_upper.map{|d| d.reverse}
       
        @polygons[i] = @convexHash.map{|lat, long| {lat: lat, lng: long}}
      end

      

      @bsonPresent = @bsonPresent.uniq
      @bsonAll = @bsonPresent.map { | place, user_id| {coord: place.location.coordinates, 
                                                        user_id: place.user_id,
                                                         }}

    puts "******BSONALL***"+"#{@bsonAll}"

    @bson = (@bsonAll.detect{ |coord| coord["coord"] = [-6.250544, 53.359755]}).tap{|h| h.delete(:coord)}

    puts "******BSONALL QUERY***"+"#{@bson}"

     @searchName = User.where(_id: @bson.select{|h| h["user_id"]})
     @name = @searchName.map { |e| e.name  }

     puts "#{@name}"






    def getUserName(coordinates)




      
    end

      # @one = [[-6.252201, 53.360206], [-6.251949, 53.360149], [-6.250962, 53.359934], 
     










  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :address)
    end
end
