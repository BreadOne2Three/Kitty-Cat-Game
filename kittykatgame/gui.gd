extends Control



var star_ref : = []

##while debug true, do debug stuff
@export var debug : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.currentLevelChanged.connect(updateStars)
	
	
	for child in $RestaurantRating/StarContainer.get_children():
		star_ref.append(child)
	updateStars()
	updateClock(1440.0)
	updateServicePerception(GameState.curr_service_perception)
	updateCleanliness(GameState.restaurant_cleanliness)
	updateAmenities(GameState.restaurant_amenities)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func updateStars():
	var level = GameState.current_level
	for i in range((GameState.max_level)/2):
		var temp = i * 2
		if level >= temp + 2:
			star_ref[i].frame = 0  # full
		elif level > (temp):
			star_ref[i].frame = 1  # half
		else:
			star_ref[i].frame = 2  # empty
			
	if debug:
		$RestaurantRating/DEBUG_Stars.text = str(level) 
		
	
func updateClock(time: float):
	if debug:
		$TimeOfDay/DEBUG_Time.text = "Time: " + str(time)
		$RestaurantStats/DEBUG/DEBUG_CUSTOMERRUSH_STATE.text = "Rush Status: " + str(FranchiseGlobal.TimeOfDay.keys()[GameState.curr_time_of_day])
		




#\/ unimplemented features
func updateServicePerception (perception : FranchiseGlobal.SERVICE_SPEED):
	$RestaurantStats/DEBUG/DEBUG_SERVICEPERCEPTION.text = "Perception: " + str(perception)




func updateCleanliness(cleanliness : float):
	$RestaurantStats/DEBUG/DEBUG_CLEANLINESS.text = "Cleanliness: " + str(cleanliness)
	pass
	
func updateAmenities(amenities : Dictionary):
	var string : String = "Amenities: \n"
	for key in amenities:
		var value = amenities[key]
		string += "\t" + str(key) + ": " + str(value) + "\n"
	$RestaurantStats/DEBUG/DEBUG_AMENITIES.text = string
