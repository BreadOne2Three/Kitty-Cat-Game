extends StaticBody2D
class_name TableObject

#@export var manualTableSize:bool = false
@export_range(1,3) var manTableSizeInt:int = 1
#@onready var Seat2Node = $Seats2
#@onready var Seat4Node = $Seats4

@export var table_num : int = 0
@onready var interact_pos_ref := $ServerInteractPos
#DropRadius checks for the party collision
#Area2D checks for mouse collision
signal party_seated(party : Party, table_num:int)
signal user_has_ticket()


var in_drop_radius : bool = false
var just_left_radius : bool = false
var is_seated : bool = false

var center_node:Node2D

#500 effects the whole restaurant, so 100%
# 250 effects direct neighbors, so 50%
#300.0 effects diagonal neighbors, so 60%
#defaults to 0%
var noise_radius_max : float = 500.0

var current_index: int = -1
var last_index: int = -1
var total_rotation: int = 0

var seats_avail : int = 2
var table_size : int = 2
var seatArray : Array[Chair] = []
var sprites = []
var occupied_by : Party = null

func isPartySeated()->bool:
	return is_seated

func getTotalRotations() -> int :
	return total_rotation

func tableSize(seats:int) -> int:
	return (seats-1)/2

func getTableSeating() -> int:
	return seats_avail
	
func getTableNum() -> int:
	return table_num
	
func getHeartLocation() -> Vector2:
	return $PartyHeartsLocation.global_position
	
#on player arrival, hand the item
signal _hand_player_item(item_info : Dictionary)
func handPlayerItem(item : String):
	_hand_player_item.emit({
		"item_type": item,
		"table_num": table_num
	})

func generateTableSize() -> int:
	#table_size = randi_range()
	return table_size

var dirty_dishes_present = false
func clearCustomers():
	dirty_dishes_present = true
	occupied_by = null
	deleteChairGhosts()
	is_seated = false

func get_nearest_index() -> int:
	var mouse_pos = get_global_mouse_position()
	var nearest_index = 0
	var nearest_distance = INF
	
	
	for i in range(seatArray.size()):
		var seat_pos = seatArray[i].global_position
		var distance = mouse_pos.distance_to(seat_pos)
		
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = i
	current_index = 0
	last_index = 0
	total_rotation = 0
	return nearest_index


func _ready() -> void:
	if not center_node:
		center_node = self
	#set graphical size of table
	seats_avail = (manTableSizeInt+1)*2
	table_size = manTableSizeInt
	$Table.frame = manTableSizeInt
		
	var left
	var right
	match(table_size):
		0:
			left = $Seats2/LeftSide.get_children()
			right = $Seats2/RightSide.get_children()
			$Seats2.visible = true
			$Seats4.visible = false
			$Seats6.visible = false
		1:
			left = $Seats4/LeftSide.get_children()
			right = $Seats4/RightSide.get_children()
			$Seats2.visible = false
			$Seats4.visible = true
			$Seats6.visible = false
		2:
			left = $Seats6/LeftSide.get_children()
			right = $Seats6/RightSide.get_children()
			$Seats2.visible = false
			$Seats4.visible = false
			$Seats6.visible = true
	right.reverse()
	
	for item in left:
		seatArray.append(item)
	for item in right:
		seatArray.append(item)
	
	for i in range(seatArray.size()):
		seatArray[i].mouse_entered_chair.connect(_on_object_mouse_entered.bind(i))

func _on_object_mouse_entered(object_index: int):
	if not in_drop_radius:
		return
	
	if current_index == -1:
		#user hasn't hovered over any yet until now
		current_index = object_index
		last_index = object_index
		return
	
	if object_index == current_index:
		# same object, user likely just moved mouse away and back
		return
	
	# calculate how much the rotation "steps" forward/backwards (positive = clockwise, negative = counterclockwise)
	var rotation_steps = calculate_rotation_direction(current_index, object_index)
	# update accordingly
	last_index = current_index
	current_index = object_index
	
	# apply rotation
	total_rotation += rotation_steps
	apply_rotation_step(rotation_steps)

func takeOrder():
	user_has_ticket.emit()


func apply_rotation_step(steps:int):
	for i in range(abs(steps)):
		var value = sign(steps)
		if value == 1: 
			rotateSprites(true)
			steps -= 1
		elif value == -1:
			rotateSprites(false)
			steps += 1
			pass
	pass

func calculate_rotation_direction(from_index: int, to_index: int) -> int:
	var object_count = seatArray.size()
	
	# calculate counterclockwise, modulo-ing the difference to stay in range
	var counterclockwise_distance = (to_index - from_index + object_count) % object_count
	# calculate clockwise, modulo-ing the difference to stay in range
	var clockwise_distance = (from_index - to_index + object_count) % object_count
	
	# determine which path is shorter
	if counterclockwise_distance <= clockwise_distance:
		return counterclockwise_distance  # positive for counterclockwise
	else:
		return -clockwise_distance  # negative for clockwise
	#feels contrary^ but this is actually visually what you want


func _process(_delta: float) -> void:
	
	if (is_circling):
		pass
	
func getDropRadiusDimensions() -> Vector2:
	return $DropRadius.shape.size

func determineInput():
	pass
	
func pull_out_chairs():
	in_drop_radius = true
	match (table_size):
		0:
			$Seats2/LeftSide.position.x -= 20
			$Seats2/RightSide.position.x += 20
		1:
			$Seats4/LeftSide.position.x -= 20
			$Seats4/RightSide.position.x += 20
		2:
			$Seats6/LeftSide.position.x -= 20
			$Seats6/RightSide.position.x += 20

func push_in_chairs():
	in_drop_radius = false
	match (table_size):
		0:
			$Seats2/LeftSide.position.x += 20
			$Seats2/RightSide.position.x -= 20
		1:
			$Seats4/LeftSide.position.x += 20
			$Seats4/RightSide.position.x -= 20
		2:
			$Seats6/LeftSide.position.x += 20
			$Seats6/RightSide.position.x -= 20

func deleteChairGhosts():
	var children = self.get_children()
	for sprite in sprites:
		sprite.queue_free() 
	sprites.clear()
	


func getSeatPos():
	return seatArray

func padSprites():
	while seatArray.size() > sprites.size():
		var temp := Sprite2D.new()
		temp.visible = false #hide the dummy sprite in case it loads
		temp.texture = preload("res://assets/customer.jpeg") # dummy transparent texture
		add_child(temp)
		sprites.append(temp)

func getServePos() -> Node2D:
	return interact_pos_ref
	
signal requestPlayer(reason : FranchiseGlobal.HIGHLIGHT, object: Node2D)
func requestServer(reason:FranchiseGlobal.HIGHLIGHT):
	requestPlayer.emit(reason, self)

#true is clockwise
#false is counterclockwise
func rotateSprites(direction:bool):
	if direction:
		sprite_rotation += 1
		sprites.insert(0, sprites.pop_back())
	else:
		sprite_rotation -= 1
		sprites.push_back(sprites.pop_front())
	for i in range(seatArray.size()):
		var tween = create_tween()
		
		tween.tween_property(sprites[i], 'global_position', seatArray[i].global_position, .1)
		
var circle_radius : float = 100.0 #max distance from center of table
#var full_circle_threshold : float = PI * 1.5
var is_circling: bool = false #*user mouse is in radius
var busy_elsewhere : bool = false #party is busy being read elsewhere
var threshold : float = .07 #threshold to classify as movement for possible rotation
#var curr_angle : float = 0.0 #value to compare with angle_threshold angle_accumulator
var prev_angle : float = 0.0 #same as curr_angle, just keeps history to determine clockwise/counterclockwise direction
var prev_mouse_pos : Vector2 = Vector2.ZERO
var start_pos : Vector2 = Vector2.ZERO #
#var center_pos : Vector2 = self.global_position #center of table

#negative means counter clockwise rotation
#positive means clockwise rotation
var sprite_rotation : int = 0 #*


var collision_size : Vector2 = Vector2(275,150)


var last_rotation_time: int = 0
var rotation_cooldown: int = 200  # minimum time between rotations, #adds padding as it can read too fast sometimes

var curr_direction : int = 0 #*

func _input(event: InputEvent) -> void:
	#if track_movement and (event is InputEventMouseButton or event is InputEventScreenTouch):
		#if event.pressed	:
			#start_pos = event.position
			#track_movement = true
	#if FranchiseGlobal.is_dragging:
		#if is_circling and (event is InputEventMouseMotion or event is InputEventScreenDrag) and len(sprites) != 0:
			#handle_motion(event.global_position)
	if Input.is_action_just_released("click"):
		is_circling = false
		in_drop_radius = false
		

	
func partySeatedHere(party : Party):
	is_seated = true
	party_seated.emit(party, table_num)
	occupied_by = party
	
	

func partyGone():
	is_seated = false
	occupied_by = null


func reset_motion():
	is_circling = false
	pass

#true means a swipe right/down clockwise
#false means swipe left/up counter clockwise
func detect_direction(direction:int) -> bool:
	if direction < 0:
		return false
	else:
		return true
#clockwise is counterclockwise
#counterclockwise and 2+ is not rotated at all


#change these \/ to a for loop instead
#if player mouse in area
func _on_area_2d_mouse_entered() -> void:
	for item in seatArray:
		item.enableCollision()
	##and if party in drop radius
	#if in_drop_radius:
		#is_circling = true
		#start_pos = get_global_mouse_position()
	#else:
		#is_circling = false
		


func _on_area_2d_mouse_exited() -> void:
	for item in seatArray:
		item.disableCollision()
	reset_motion()


func _on_server_interact_pos_body_entered(body: Node2D) -> void:
	print('inside interact')
	if body is Player:
		print('arrived')
		body = body as Player
		occupied_by.onPlayerArrival()
		pass
	pass # replace with function body.

func prepareTableForFood():
	occupied_by.prepareForFood()
	pass
