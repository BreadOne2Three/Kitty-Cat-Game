extends Node2D

@onready var table_spawn_node = $TableSpawn_Nodes
var table_spawn_node_NAME = "TableSpawn_Nodes/"
@onready var camera = $CameraNode/Camera
@onready var dishes_spawner = $Counter #so we can reference and call spawn functions
@onready var party_spawner = $PartySpawner
@onready var timer = $LengthOfDay
@onready var recalculate_timer = $RecalculateTimers
@onready var camera_pan_left_btn = $CameraNode/EntranceFromMainDiningArrow
@onready var camera_pan_right_btn = $CameraNode/MainDiningFromEntranceArrow
@onready var navigation_region := $WorldTileMapLayers
@onready var player := $Player
var table_spawns : Dictionary
#^ an array/dictionary of all tables possible spawns 
#@onready var player = $Player #so the player character can be given commands

#var x_max : int = 640
#var y_max : int = 360
var x_increment : int = 80
var y_increment : int = 45

var dragging : bool = false

var customer_wave_state : FranchiseGlobal.TimeOfDay = FranchiseGlobal.TimeOfDay.CLOSED

enum GameMode {EDITOR, PLAY}
var current_mode = GameMode.EDITOR

func switch_to_play_mode():
	current_mode = GameMode.PLAY
	


#SPAWN REFERENCES
var table_ref = preload("res://scenes/franchise_mode/customerTable.tscn")



@export var level_script : String #reference to the level script name
var level_data : Dictionary
var level_path : String = "res://scenes/franchise_mode/levels/scripts/"
var table_dict : Array = []
var cust_dict : Array = []



#JSON level lata
var table_spawn : String = "obs_spawn"
var customer_spawn : String = "enemy_parties"
var day_time : String = "day_time"

#sub JSON values
var seats_at_table : String = "seats"
var table_pos : String = "table_pos"


var day_timer : float = 1440.0


var spawn_party_size : int = 1
var spawn_party_type : FranchiseGlobal.PARTY_TYPE = FranchiseGlobal.PARTY_TYPE.NORMAL
var spawn_party_colors = []


func getTableSpawnNode(node_coord : String) -> Node2D:
	return get_node(table_spawn_node_NAME+node_coord)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	var temp_spawn = $TableSpawn_Nodes.get_children()
	for child in temp_spawn:
		table_spawns[child] = false
		
	
	#print(level_path+level_script+".json")
	#var file = FileAccess.open(level_path + level_script + ".json", FileAccess.READ)
	#var json_string = file.get_as_text()
	#level_data = JSON.parse_string(json_string)
	
	for table in $TableSpawns.get_children():
		table.connect("user_has_ticket", enableTicketSubmission)
		table.connect("_hand_player_item", handPlayerItem)
		table.connect("requestPlayer", requestPlayer)
	
	
	levelBeginPrompt() #replace \/this with <-this
	timer.start(day_timer)
	
	#every 10 seconds, determine what phase of customers to have
	recalculate_timer.start(10.0)
	
	
	
	#
	#load_tables() #finished??
	#load_parties() 
	#
	#load_level_scripts()
	
	navigation_region.bake()
func requestPlayer(reason : FranchiseGlobal.HIGHLIGHT, body: Node2D):
	player.queueAction(reason, body)
	pass

func handPlayerItem(item : Dictionary):
	player.addItemToInventory(item["item_name"], item["table_num"])
	pass
func enableTicketSubmission():
	pass
	
func startCookingForTable(number:int):
	pass
func userHasTicketFrom(table : int):
	
	pass
#this enables the loading of things such as tool tips, announcements
#or even events. 
#for example, a player encounters the critic for the first time 
#or is on the first level and needs a tutorial 
#or just making certain tables blink to 
func load_level_scripts(): 
	pass

func levelBeginPrompt():
	
	pass
	
func confirmedBegin():
	pass

func load_tables():
	table_dict = level_data[table_spawn] 
	for item in table_dict:
		print(item[table_pos])
		var pos_string = item[table_pos]  # "(5.0, 5.0)"
		# Remove parentheses and split by comma
		var coords = pos_string.strip_edges().trim_prefix("(").trim_suffix(")").split(",")
		var pos = Vector2(float(coords[0]), float(coords[1]))
		spawn_table(item[seats_at_table], pos)
		
func spawn_table(size:int, location:Vector2):
	#value 'size' passed in is the number of seats at the table, 
	#tableSize has to be a value 0, 1, or 2, so the value needs to be calculated
	var temp_ref = table_ref.instantiate()

	temp_ref.manualTableSize = true
	temp_ref.manTableSizeInt = int(size-1)/2
	
	add_child(temp_ref)
	var pos = location
	pos.x = pos.x * x_increment
	pos.y = pos.y * y_increment
	temp_ref.global_position = pos
	
	pass
	
func getNodeLocations(node_name:String) -> Vector2:
	var string_path = table_spawn_node_NAME+node_name
	var node = get_node(string_path)
	
	return node.global_position
	
	
func load_parties():
	cust_dict = level_data[customer_spawn]
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if isItTimeToSpawn():
		spawnNext()
	#if confirmed level prompt
		#confirmedBegin()
	pass


func isItTimeToSpawn() -> bool:
	return false
	
func spawnNext():
	pass

func _on_timer_timeout() -> void:
	print('day ended')

signal updateClock(time:float)
func _on_recalculate_timer_timeout() -> void:
	#determine the current state of customers (breakfast rush? lunch rush?)
	customer_wave_state = GameConfig.calculateTimeOfDay(timer.time_left)
	GameState.curr_time_of_day = customer_wave_state
	#on a scale from 0-100% chance of every 10 seconds a customer spawns
	var customer_weight = GameConfig.getTimeOfDayWeight(customer_wave_state)
	
	# unimplemented right now
	#will be a sum of aesthetic, dirtiness, and general perceived reputation (NOT the 5 start weight)
	var restaurant_weight = GameConfig.calculateServiceSpeed(GameState.average_service_time)
	var weight : float = 0.0
	if customer_weight != 0.0:
		weight = ( customer_weight - restaurant_weight ) + (GameState.current_level / 50)
	
	updateClock.emit(abs(floor(GameState.LengthOfDay - $LengthOfDay.time_left)))
	
	spawnCustomerOrNot(weight)
	#calculate spawn chance 
	pass # Replace with function body.

func spawnCustomerOrNot(weight : float):
	var generated = randf()
	print("Weight: ", weight)
	print("Generated Weight: ", generated)
	if generated < weight:
		#spawn
		print("spawning")
		spawnThisParty(spawnWhatTypeOfCustomer(), spawnWhatSizeOfParty())
		pass
	else:
		print("not spawning")
		return

func spawnWhatTypeOfCustomer() -> FranchiseGlobal.PARTY_TYPE:
	var customer_weights = GameConfig.getRestaurantLevelCustomers(GameState.current_level)
	var weights = 0.0
	for weight in customer_weights.values():
		weights += weight
		
	var random_comp_weight = randf() * weights
	
	var current_weight = 0.0
	for key in customer_weights.keys():
		current_weight += customer_weights[key]
		if random_comp_weight <= current_weight:
			return key
			
	#emergency behavior and whatnot, shouldn't happen
	return weights.keys()[0]
	
	
func spawnWhatSizeOfParty() -> int:
	return randi_range(FranchiseGlobal.MIN_CUSTOMERS_PER_TABLE, FranchiseGlobal.MAX_CUSTOMERS_PER_TABLE)


	
func spawnThisParty(disposition : FranchiseGlobal.PARTY_TYPE, size: int):
	party_spawner.spawn_party(true, disposition, size)
	pass


func resetUIDisplay():
	pass
