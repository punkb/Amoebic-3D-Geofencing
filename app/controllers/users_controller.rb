class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
 def show

   #Event Section Start
   @events = Event.all
   @eTitle = Array.new
   @eCoord = Array.new

   @events.each do |e|
    @eTitle << e.name
    @eCoord << e.location
   end
    @currentEvent = @eTitle[0]
    @currentEventCoord = @eCoord[0] #Event Coordinate to search first set of users

  #Event section Ends

    @present = Array.new
    @boundary = Array.new
    @distance = 0.00001

  

  def search (coordinates, distance)
    @searchResult = Place.geo_near(coordinates).spherical.max_distance(distance)
    if (@searchResult).empty? 
    if distance < 0.0001 
      distance =+ 0.00001
      search(coordinates, distance)
    end
      
    else
      return @searchResult
    end
  end


  def first_userSet(coordinates, distance)

    puts "*******Calling Search from first User"
    puts coordinates 
    puts distance
    puts "******************"

    search(coordinates, distance)

    puts "******* Searched from first_User"
    
    puts "******************"

    puts
    if (@searchResult).empty?
      #do Nothing
     
    else
      @neighbours_coord =  Array.new
      @neighbours_id = Array.new
      @neighbours_coord = @searchResult.map { |c| c.location.coordinates }
      @neighbours_id = @searchResult.map { |c| c.user_id }
      @present = @neighbours_coord
    end
  end

  puts "*****Present before rec***********"
  puts @present


  first_userSet(@currentEventCoord, @distance)
  

  def search_neighbour_rec(coordinates, distance)

    @next_neighbours = Array.new()
    

    for i in 0..(coordinates.length-1)
      

      current_neighbours = Array.new

      @current_user = coordinates[i]

      puts "*******Calling Search from rec"
      puts i
    puts @current_user 
    puts distance
    puts "**********@present********"
    puts @present
     puts "**********@boundary********"
    puts @boundary
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

      search(@current_user, distance)

      current_neighbours = @searchResult.map { |c| c.location.coordinates }

      puts "*******current_neighbours*****"
      puts current_neighbours
      puts "***********************"

      #find Uniq/new coordinates
      @uniqCoords = current_neighbours - @present
       # @uniqCoords = @present - current_neighbours

      puts "*******uniqCoords*****"
      puts @uniqCoords
      puts "***********************"
      if @uniqCoords.empty?
        @boundary = @searchResult.map { |c| c.location.coordinates }
         # current_neighbours.each do |u| 
         # @boundary << u 
         # end       
      else
        @uniqCoords.each do |u|
         @present << u 
         @next_neighbours << u
         end 
      end
    end

    if (@next_neighbours).empty?
      
    else
       puts "**********FirstRec Called********"
    puts @next_neighbours
    puts @distance
    puts "888888888888888888888888888888888888888"
      search_neighbour_rec(@next_neighbours, @distance)
    end    
  end

  search_neighbour_rec(@present, @distance)
  puts "*****Present after rec***********"
  puts @present

# @neighbours_coord.each do |d|
#   @boundary << d
# end

@corkParkBoundary = [[53.361547, -6.252126], [53.361483, -6.252163], [53.361397, -6.252217], [53.361323, -6.252249], [53.361253, -6.252319], [53.361157, -6.252378], [53.361080, -6.252458], [53.360977, -6.252490], [53.360897, -6.252560], [53.360753, -6.252630], [53.360609, -6.252716], [53.360452, -6.252796], [53.360292, -6.252882], [53.360081, -6.252844], [53.360010, -6.252863], [53.359777, -6.252437], [53.359719, -6.252077], [53.359580, -6.251452], [53.359450, -6.250908], [53.359530, -6.250345], [53.359714, -6.250125], [53.359860, -6.250066], [53.359874, -6.250125], [53.360225, -6.249883], [53.360398, -6.249808], [53.360478, -6.249720], [53.360614, -6.249690], [53.360755, -6.249612], [53.360923, -6.249500], [53.360897, -6.249524]]


end




  

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
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
