class UsersController < ApplicationController
   before_action :set_user, only: [:edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
 def show

 # @test = Place.where(:"location.height".gt => 5)
 # @test = @test.map { |e| e.location.coordinates  }

  # @test = Place.geo_near([-6.2515651, 53.3609245]).spherical.average_distance

@bsonPresent = Array.new
@heightAll = Array.new

   #Event Section Start
   @events = Event.all
   @eTitle = Array.new
   @eCoord = Array.new


   @events.each do |e|
    @eTitle << e.name
    @eCoord << e.location
   end
    @currentEvent = @eTitle[1]
    @currentEventCoord = @eCoord[1] #Event Coordinate to search first set of users

    puts "******************Start Event******************"
    puts "Event Name"
    puts @currentEvent
    puts "****Event Coordinates"
    puts @currentEventCoord
    puts "******************End Event******************"

  #Event section Ends

    @present = Array.new
    @finalPolygon = Array.new
    @presentName = Array.new
    @boundary = Array.new
    @fixDist = 5/6378139.266
      @distance = 5/6378139.266
      @distInMeter = 5
      #0.00000016
     # @distance = 0.00001
    # @FinalDist = 

#     SPHERICAL QUERIES USE RADIANS FOR DISTANCE
# For spherical operators to function properly, you must convert distances to radians, and convert from radians to the distances units used by your application.

# To convert:

# distance to radians: divide the distance by the radius of the sphere (e.g. the Earth) in the same units as the distance measurement.
# radians to distance: multiply the radian measure by the radius of the sphere (e.g. the Earth) in the units system that you want to convert the distance to.
# The radius of the Earth is approximately 3963.192 miles or 6378.137 kilometers.
# 3 963.192 mile = 20 925 653.76 feet
# 3 963.192 mile = 6 378 139.266 meter

  

  def search (coordinates, distance)
    @check = Array.new
    @searchResult = Place.geo_near(coordinates).spherical.max_distance(distance)
    @resultCoords = @searchResult.map { |e| e.location.coordinates  }
    @check << coordinates
    puts "@check"+"#{@check}"
    puts "@resultCoords"+ "#{@resultCoords}"


    checkEmpty = @resultCoords - @check
     puts "checkEmpty"+"#{checkEmpty}"
    if checkEmpty.empty? || (checkEmpty-@present).length < 2 
      puts "*********SEARCH RESULT IS EMPTY********"
        if distance <= 100/6378139.266
          distance = (distance+@fixDist)
          @distInMeter += 5

          # for i in 2..20
          #   distance = i/6378139.266
            puts "******* Now Searching for distance: "+"#{@distInMeter}"+"meters"
            search(coordinates, distance)
        
        end
      
    else
      puts "******"+" #{checkEmpty.length} "+"Users found withing distance = "+"#{@distInMeter}"+"meters"+"*********"
      @distInMeter = 5



      @searchResult.map { |e| @bsonPresent << e  }
       @bsonPresent = @bsonPresent.uniq
      @bsonPresent.map { |e| @heightAll << e.height  }
     


      return @searchResult
    end
    @distInMeter = 5
  end

  def get_userName(id)
    @result = User.where(_id: id)
    @userName = @result.map { |e| e.name  }
    return @userName
    
  end



  def first_userSet(coordinates, distance)

   puts "****Start In first_userSet******"
   puts "first_userSet"+"(""#{coordinates}"+"," "#{distance}"+")"
   puts "search"+"("+"#{coordinates}"+","+","+"#{distance}"+")"

    search(coordinates, distance)

    if (@searchResult).empty?
      #do Nothing
      puts "*****@searchResult.empty?****"
     
    else
      @neighbours_coord =  Array.new
      @neighbours_id = Array.new
      @neighbours_height = Array.new
      @place_id = Array.new
      @names = Array.new
      @neighbours_coord = @searchResult.map { |c| c.location.coordinates}
      @neighbours_height = @searchResult.map { |c| c.height }

      @neighbours_id = @searchResult.map { |c| c.user_id }
      puts "*******@neighbours_id: "
      @neighbours_id.each do |x|
        get_userName(x)
        @names << @userName
      end
      puts "*******@neighbours_names:"
      puts @names
      @place_id = @searchResult.map { |c| c._id }
      @present = @neighbours_coord
      @finalPolygon = @neighbours_coord

      
      puts"@Present before rec: = first_userset @neighbours_coord: "+"["+"#{@neighbours_coord}"+"]"
    end
  end

  

  def printArrayToConsole(a)
    a.each do |x|
      puts "#{x}"
    end
    
  end
  

  def search_neighbour_rec(coordinates, distance)


     puts "****WE ARE INSIDE THE RECURSIVE LOOP******"
     puts "**********@PRESENT ARRAY: ********"
       printArrayToConsole(@present)
       puts "**********@BOUNDARY ARRAY********"
       if @boundary.empty?
        puts "*******@boundary Array is empty********"
       else 
        printArrayToConsole(@boundary)
      end

   @next_neighbours = Array.new()


    puts "******FOR LOOP START****"
    for i in 0..(coordinates.length-1)

      current_neighbours = Array.new()
      @n_id = Array.new
   @n_names = Array.new

      @current_user = coordinates[i]

     puts "*******SEARCHING FOR "+"#{i}"+"th"+"USER COORD***"
     puts "search"+"("+"#{@current_user}"+","+","+"#{distance}"+")"

      search(@current_user, distance)


      current_neighbours = @searchResult.map { |c| c.location.coordinates }
      @n_id = @searchResult.map { |c| c.user_id }
      puts "*******@neighbours_Names: "
      @n_id.each do |x|
        get_userName(x)
        @n_names << @userName
      end
      puts "*******@neighbours_names:"
      puts @n_names

      puts "***CURRENT NEIGHBOURS FROM SEARCH RESULT FOR"+"#{@current_user}"
      printArrayToConsole(current_neighbours)


      #find Uniq/new coordinates
      @uniqCoords = current_neighbours - @present
       # @uniqCoords = @present - current_neighbours

      puts "***UNIQUE CORDS/USERS :*****"
      printArrayToConsole(@uniqCoords)
     
      if @uniqCoords.empty?

        puts "***UNIQUE CORDS ARE EMPTY ..MEANSE THE LAST SEARCH RESULTS ARE BOUNDARY ELEMENTS*****"
         @boundaryTemp = @searchResult.map { |c| c.location.coordinates }
         @boundaryTemp = @boundaryTemp - @boundary
        puts "**********BOUNDARY BEFORE*********** "
         printArrayToConsole(@boundary)
         puts "************PUSHING BOUNDARYTEMP TO BOUNDARY "
         printArrayToConsole(@boundaryTemp)
        

        @boundary << @current_user
        #  @boundaryTemp.each do |u|
        #   @boundary << u
        # end
         puts "***************BOUNDARY AFTER *********"
         printArrayToConsole(@boundary)
          # current_neighbours.each do |u| 
          # @boundary << u 
          # end       
      else
        puts "********PUSHING UNIQUE COORDS INTO @PRESENT[] and @NEXT_NEIGHBOURS******"
        @uniqCoords.each do |u|
         @present << u 
         @next_neighbours << u
         end 
      end
    end

    puts "*****FOR LOOP ENDS***"

    if (@next_neighbours).empty?
      puts "******NO MORE COORDINATES TO SEARCH****"
      
    else
      
      puts "NOW SEARCH FOR NEXT NEIGHBOURS"
      puts "search_neighbour_rec"+"("+"#{@next_neighbours}"+","+"#{distance}"+")"
      search_neighbour_rec(@next_neighbours, distance)
    end    
  end

            puts " SEARCHING FIRST USER SET "
            puts "first_userSet"+"("+"#{@currentEventCoord}"+","+"#{@distance}"+")"
first_userSet(@currentEventCoord, @distance)


            puts " SEARCHING NEIGHBOURS OF FIRST USER SET "
            puts "search_neighbour_rec"+"("+"#{@present}"+","+"#{@distance}"+")"
  search_neighbour_rec(@present, @distance)

@polygon = Array.new
@polygon << @finalPolygon[0]
  @boundary.each do |x|
    @polygon << x
  end
  @polygon << @finalPolygon[1]



  puts "*****FINAL PRESENT ARRAY: ***********"
  printArrayToConsole(@present)

  puts "*****FINAL BOUNDARY ARRAY: ***********"
  printArrayToConsole(@boundary)

# @neighbours_coord.each do |d|
#   @boundary << d
# end
@height = Array.new
@maxHeightSet = Place.desc(:height)
@distinctHeight = Place.all.distinct(:height) 

@distinctHeight.each do |d|
@height << d
end

@firstSet = Place.where(height: @height[0])
@firstSetCoord = @firstSet.map { |e| e.location.coordinates }

@secondSet = Place.where(height: @height[1])
@secondSetCoord = @secondSet.map { |e| e.location.coordinates  }


#New Logic


      @heightLimits = @heightAll.uniq
      @minHeight = @heightAll.min
      @maxHeight = @heightAll.max

      @bsonHash = @bsonPresent.map { | place, user_id, height| {lat: place.location.coordinates[1], 
                                                                      lng: place.location.coordinates[0],
                                                                      alt: place.height}}


    
      # @groupedArray = @bsonHash.group_by{|x| "alt_#{x['alt']}".values}
        @groupedArray = @bsonHash.group_by{|x| x[:alt]}.values
        @minHeightArray = @groupedArray[0]
        @maxHeightArray = @groupedArray[1]

        @minHeightArray << @minHeightArray[0]
        @maxHeightArray << @maxHeightArray[0]

        @points = Array.new
        @points2 = Array.new

        # @minHeightArray.each do |p|
        #    p = p.tap {|hs| hs.delete(:alt)}
        #   @points << p.values.reverse
        # end

        #due to tap alt values are not in the hash anymore

        @minHeightArray.map { |e| @points << (e.tap {|hs| hs.delete(:alt)}).values.reverse  }
        @maxHeightArray.map { |e| @points2 << (e.tap {|hs| hs.delete(:alt)}).values.reverse  }

      

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
  @convexHash = @lower_upper.map{|d| d.reverse}
 
  return @convexHash
        
  end

      convex_hull(@points)

      @innerPolygon =  @convexHash.map{|lat, long| {lat: lat, lng: long}}
     

      
      convex_hull(@points2)
      @outterPolygon =  @convexHash.map{|lat, long| {lat: lat, lng: long}}

      








#End of SHOW
end




  

  # GET /users/new
  def new
    @user = User.new
   @place = Place.new
    # @lat = request.location.latitude
    # @lng = request.location.longitude
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @place = Place.last

    respond_to do |format|
      if @user.save
        @user.places << @place
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name)
    end
end
