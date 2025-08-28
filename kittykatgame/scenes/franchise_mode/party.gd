class_name Party
extends Node2D

signal party_seated #maybe add the table as well eventually? not really needed though

#@export var array : Array = []

@onready var debug_win = $debug_textpopup
@onready var timer = $EventTimers
@onready var floating_text = "res://scenes/franchise_mode/floating_text.tscn"

#keep track of whether party is seated so they can't be dragged out of a table
var draggable = false
#not sure of difference here?
var is_seated = false

#determine if party is in droppable zone for table
var is_inside_dropable : = false
var busy_with_other_table : = false
var table_in_question
var neighbouring_table = null

var serve_status : int = 0
var serve_times : Dictionary = {}
@export var order_data : OrderData

@export var party_disposition : FranchiseGlobal.PARTY_TYPE = FranchiseGlobal.PARTY_TYPE.NORMAL


#reference to the table object the party is hovering over
#cleared on exit but not placement
var body_ref



#pixel offset for each customer in party
var customerOffset:int = 50

#initial position of the party when picked up, used for dragging it
var initialPos:Vector2
#offset variable for the movement of party behind mouse pos
var offset:Vector2

#ignore integer division since it is necessary
@warning_ignore('integer_division')

#preload the customer object for spawning in up to 6 customers
var customer_scene = preload("res://scenes/franchise_mode/customer.tscn")

#max value for party health currently (can change if this needs balancing
var party_max_health := 5.0
#current health(defaults to max health since they spawn in)
#may change this to a random value influenced by party disposition e.g. impatient
var party_curr_health := party_max_health
#bool for dirty data check so we aren't redrawing the heart each frame
var health_changed := false


#smallest a party can be
const min_party_size : int = 1
#largest a party can be
const max_party_size : int = 4
#actual party size
var party_size : int


#this is the array that contains the enum value for the party color order for combos
#this array needs to be rotated with party_order
var party_color := []

#order of party -- compared against seat_pos to determine seating
#this is the array that is rotated
var party_order := []

#ROTATION OBJECTS
#initial position for mouse enterring body
var original_pos := Vector2.ZERO

#position of all seat positions at each chair object found in customerTable/customerChair
var seat_pos := []

#reference to the customers that are added the party
var customer_children := []

#heart sprites
var heart_ref := []


var party_timers : Dictionary = {}
var current_timer : FranchiseGlobal.TIMER_NAMES = FranchiseGlobal.TIMER_NAMES.NOTHING

var player 
func _ready() -> void:
	#connect signals
	party_seated.connect(onPartySeated.bind(self))
	player = get_tree().get_first_node_in_group("player")
	
	#populate heart references
	var children = $HeartContainer.get_children()
	#have hearts referenced for health function
	for child in children:
		heart_ref.append(child)
		


func _process(_delta: float) -> void:
	
	#$debug_textpopup.setText()
	if (draggable):
		#global_position = get_global_mouse_position() - offset
		havePartyHugMouse()
		if is_inside_dropable and body_ref.is_seated == false:
			sprite_nodes.visible = false
		
		#snap back to original position OR go to new one
	elif just_released_mouse:
		FranchiseGlobal.is_dragging = false
		var tween = create_tween()
		#we're inside the new zone
		if (is_inside_dropable) and body_ref.is_seated == false:
			is_seated = true
			
			tween.tween_property(self, "global_position", body_ref.global_position, .2).set_ease(Tween.EASE_OUT)
			body_ref.partySeatedHere(self)
			party_seated.emit()
		#else, go where you were
		else:
			resetPartyToOrigin()
		just_released_mouse = false
	if (health_changed):
		redrawHealth()
		health_changed = false
	
##is the object passed in equal to self?
func isCollectionRadius(object:Area2D):
	return (object == $Area2D)
##upon party being seated, begin timers and whatnot

func resizeHitboxToTable():
	var new_shape = RectangleShape2D.new()
	new_shape.size = body_ref.getDropRadiusDimensions()
	$Area2D/collection_radius.shape = new_shape
	clicker.size = $Area2D/collection_radius.shape.size
	clicker.position = Vector2(-((clicker.size.x)/2), -((clicker.size.y)/2))
	clicker.visible = true

var table_num : int = 0

func onPartySeated(party):
	resizeHitboxToTable()
	#pad out party to max size to calculate necessary rotations
	body_ref.user_has_ticket.connect(startWaitingForFood)
	if party_order.size() < body_ref.getTableSeating():
		while party_order.size() < body_ref.getTableSeating():
			party_order.append(null)
	#get rotation value
	var rotations = body_ref.getTotalRotations()
	#rotate it
	for i in range(abs(rotations)):
		var value = sign(rotations)
		if value == 1: 
			rotateSprites(true)
			rotations -= 1
		elif value == -1:
			rotateSprites(false)
			rotations += 1
			pass
	table_num = body_ref.getTableNum()
	current_timer = FranchiseGlobal.TIMER_NAMES.ORDERING
	#start menu timer
	timer.start(party_timers[GameConfig.getTimerDictKey(current_timer)])
#true is clockwise
#false is counterclockwise
func rotateSprites(direction:bool):
	if direction:
		party_order.insert(0, party_order.pop_back())
	else:
		party_order.push_back(party_order.pop_front())

func generateTimeToCompleteMenu() -> float:
	match(party_disposition):
		FranchiseGlobal.PARTY_TYPE.PATIENT:
			pass
		FranchiseGlobal.PARTY_TYPE.NORMAL:
			pass
	return 0.0

func init(size : int, disposition: FranchiseGlobal.PARTY_TYPE, timer_array : Dictionary):
	#get party type
	setPartyType(disposition)
	#get party size AND spawn customers
	setPartySize(size)
	#parse dictionary into another dictionary for access
	parsePartyTimerArray(timer_array)

func parsePartyTimerArray(array : Dictionary):
	party_timers = array

#`array` allows for manual assignment if i wanted to do that
func assignColors(array:Array[FranchiseGlobal.PARTY_COLOR] = []):
	#if array is empty(non-manual spawning)
	if len(array) == 0:
		for i in range(party_size):
			#generate color
			var x: FranchiseGlobal.PARTY_COLOR = FranchiseGlobal.PARTY_COLOR[FranchiseGlobal.PARTY_COLOR.keys()[randi() % FranchiseGlobal.PARTY_COLOR.size()]]
			#append the color to the array in case needed for seating combo
			party_color.append(x)
			#spawn customer
			spawnCustomer(x)
	else:
		for i in range(len(array)):
			var x = array[i]
			var y : FranchiseGlobal.PARTY_COLOR
			match(x):
				"red":
					y = FranchiseGlobal.PARTY_COLOR.RED
				"blue":
					y = FranchiseGlobal.PARTY_COLOR.RED
				"yellow":
					y = FranchiseGlobal.PARTY_COLOR.RED
				"green":
					y = FranchiseGlobal.PARTY_COLOR.RED
				"random":
					y = FranchiseGlobal.PARTY_COLOR[FranchiseGlobal.PARTY_COLOR.keys()[randi() % FranchiseGlobal.PARTY_COLOR.size()]]
					
			party_color.append(y)
			spawnCustomer(y)
	
func spawnCustomer(color: FranchiseGlobal.PARTY_COLOR):
	var newCustomer = customer_scene.instantiate() as Customer
	self.add_child(newCustomer) #add to tree
	customer_children.append(newCustomer)
	
	#connect Customer signals
	newCustomer.draggingParty.connect(_party_dragging)#it's not autofilling like it has before
	newCustomer.doneDraggingParty.connect(_party_finished_dragging)
	
	#initialize function
	newCustomer.init(color)      # Then initialize
	
	# Position after adding to scene tree
	var len = party_order.size()
	newCustomer.global_position.x += len * customerOffset
	customer_children_original_pos.append(newCustomer.global_position)
	party_order.append(newCustomer)

var customerBeingHandled : Sprite2D = null
func _party_dragging(one_being_dragged : Customer):
	$Area2D/collection_radius.disabled = false #enable hitbox
	offset = get_global_mouse_position() - global_position #add offset (instead of center)
	customerBeingHandled = unhideSprites(one_being_dragged)
	#customerBeingHandled = one_being_dragged #so it is ignored by the tweening
	recenterParent() #move the Hearts and the hitbox (and other parts) with the mouse

	draggable = true
func _party_finished_dragging():
	#$Area2D/collection_radius.disabled = true #disable hitbox
	just_released_mouse = true #for cleanup operations in _process()
	customerBeingHandled = null #reset customer being handled for null checks
	draggable = false #disable dragging

#set entire party object to the leading customer
func recenterParent():
	# move parent to the new center
	self.global_position = customerBeingHandled.global_position

var just_released_mouse : bool = false

func resetPartyToOrigin():
	if not is_inside_dropable:
		self.global_position = initialPos
		self.global_position.x -= (party_size*60)
		self.global_position.y = get_parent().global_position.y
		hideSprites()
		for i in range(len(customer_children)):
			customer_children[i].moveToPos(customer_children_original_pos[i])
		
func takePatienceDamage(amount : float):
	
	
	
	redrawHealth()
	pass
func healPatience(amount: float):
	pass
	
func redrawHealth():
	for i in range(party_max_health):
		if party_curr_health >= i + 1:
			heart_ref[i].frame = 0  # full
		elif party_curr_health > i:
			heart_ref[i].frame = 1  # half
		else:
			heart_ref[i].frame = 2  # empty

		
func _on_area_2d_mouse_entered() -> void:
	pass
	##user grabbed party
	#if (not FranchiseGlobal.is_dragging) and (not is_seated):
		#highlight(true)
		#draggable = true
		##scale = Vector2(1.05, 1.05)
	#else:
		##design it so you can rotate customers around chairs
		#pass

func _on_area_2d_mouse_exited() -> void:
	pass
	##user let go of mouse in range of seating
	#if not FranchiseGlobal.is_dragging:
		#highlight(false)
		#draggable = false
		##scale = Vector2(1, 1)
	#


func _on_area_2d_body_entered(body: StaticBody2D) -> void:
	if body.is_in_group("dropable") and body.isPartySeated() == false:
		if party_size <= body.getTableSeating():
			body_ref = body
			is_inside_dropable = true
			#reset party
			body.pull_out_chairs()
			getInFormation(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("dropable") && party_size <= body.getTableSeating() and body.isPartySeated() == false:
		is_inside_dropable = false
		body.push_in_chairs()
		body.deleteChairGhosts()
		resetFormation(body)
		
		for child in self.get_children():
			if child is Customer:
				child.visible = true
		

func getInFormation(body: StaticBody2D):
	var parent = self
	# Collect only Sprite2D nodes (or another type you want)
	for child in parent.get_children():
		if child is Customer:
			child.visible = false
			var temp : Sprite2D = Sprite2D.new()
			temp.texture = child.getSprite()
			temp.modulate = child.getModulate()
			temp.scale = child.getScale()
			body.add_child(temp)
			body.sprites.append(temp) #append temp object to sprites array for easier deletion
	body.padSprites()
	seat_pos = body.getSeatPos()
	var indice = body.get_nearest_index()
	for i in range(len(body.sprites)):
		body.sprites[i].global_position = seat_pos[(i+indice)%seat_pos.size()].chairPos()
		
	
func resetFormation(body: StaticBody2D):
	# Before generating new sprites
	body.deleteChairGhosts()

func cleanUpPartyDELETE():
	for i in range(party_size):
		party_order[i].queue_free()

var mouse_radius : int = 50

#func getSprite():
	#return $Sprite2D.texture
#func getModulate() -> Color:
	#return $Sprite2D.modulate
#func getScale() -> Vector2:
	#return $Sprite2D.scale
@onready var sprite_nodes = $SpriteNodes
var customer_trail_sprites_ref = []
func createTrailingCustomersSprites():
	for i in range(len(customer_children)):
		var sprite = Sprite2D.new()
		sprite.texture = customer_children[i].getSprite()
		sprite.modulate = customer_children[i].getModulate()
		sprite.scale = customer_children[i].getScale()
		sprite_nodes.add_child(sprite)
		customer_trail_sprites_ref.append(sprite)
		sprite.global_position = customer_children[i].global_position
		sprite.visible = false

func cleanupTrailingCustomerSprites():
	for child in $SpriteNodes.get_children():
		child.queue_free()


var begin_sprite_trailing : bool = false
func unhideSprites(follower : Customer):
	var customer_to_drag
	for i in range(len(customer_trail_sprites_ref)):
		customer_trail_sprites_ref[i].visible = true
		customer_children[i].visible = false
		if customer_children[i] == follower:
			customer_to_drag = customer_trail_sprites_ref[i]
	begin_sprite_trailing = true
	return customer_to_drag
	
func hideSprites():
	for i in range(len(customer_trail_sprites_ref)):
		var tween = create_tween()
		tween.finished.connect(_finished_tweening_ghost_sprites.bind(i))
		tween.tween_property(customer_trail_sprites_ref[i], "global_position", customer_children[i].global_position, tween_time)

func _finished_tweening_ghost_sprites(index_ref : int):
	customer_children[index_ref].visible = true
	customer_trail_sprites_ref[index_ref].visible = false
	
var min_move_noise : float = 0.0
var max_move_noise : float = 25.0
var tween_time : float = .25
func moveSpritesToPos():
	for sprite in customer_trail_sprites_ref:
		var tween = create_tween()
		tween.tween_property(sprite, "global_position", generatePosWithNoise(get_global_mouse_position()), tween_time)
		
func generatePosWithNoise(pos : Vector2) -> Vector2:
	return Vector2(pos.x + randf_range(min_move_noise, max_move_noise), pos.y + randf_range(min_move_noise, max_move_noise))
#party as a whole navigates to locations
#customers have extra 'noise' in navigation
func moveIdleParty():
	pass

var tween_speed : float = .5

var justGotDropped : bool = false
func havePartyHugMouse():
	var mouse_pos = get_global_mouse_position()
	self.global_position = mouse_pos
	if (not is_inside_dropable) and (FranchiseGlobal.is_dragging):
		for customer in customer_trail_sprites_ref:
			if customer != customerBeingHandled:
				#TODO tween function
				var target = generatePosWithNoise(mouse_pos)
				var tween = create_tween()
				#ease in out
				tween.tween_property(self, "global_position", target, tween_speed).set_ease(Tween.EASE_IN_OUT)

				#customer.moveToPos(Vector2(mouse_pos.x + randi_range(-mouse_radius, mouse_radius), mouse_pos.y + randi_range(-mouse_radius, mouse_radius)))
				pass
			else:
				customer.global_position = get_global_mouse_position()
	elif is_inside_dropable and body_ref.isPartySeated() == true:
		return
#replace node movements with sprite duplicates just like the tables do^^^^^
var customer_children_original_pos : Array = []
func setPartySize(size : int):
	party_size = size
	assignColors()
	updateDebug()
	createTrailingCustomersSprites()

func setPartyType(type: FranchiseGlobal.PARTY_TYPE):
	var resource : String
	match type:
		FranchiseGlobal.PARTY_TYPE.PATIENT:
			resource = "res://scenes/franchise_mode/resources/patientCustomerResource.tres"
			
		FranchiseGlobal.PARTY_TYPE.NORMAL:
			resource = "res://scenes/franchise_mode/resources/normalCustomerResource.tres"
			pass
		FranchiseGlobal.PARTY_TYPE.IMPATIENT:
			resource = "res://scenes/franchise_mode/resources/impatientCustomerResource.tres"
			pass
		FranchiseGlobal.PARTY_TYPE.CRITIC:
			resource = "res://scenes/franchise_mode/resources/criticCustomerResource.tres"
			pass
	order_data = load(resource).duplicate(true)
	party_disposition = type
	updateDebug()
	#set sprite accordingly

func updateDebug():
	var string : String = FranchiseGlobal.PARTY_TYPE.keys()[party_disposition] + "\n" + str(party_size)
	debug_win.setText(string)

func _on_event_timer_timeout() -> void:
	$EventClicker.text = "ACTIVE"
	
	if current_timer == FranchiseGlobal.TIMER_NAMES.ORDERING:
		$EventClicker.disabled = false
		pass
	elif current_timer == FranchiseGlobal.TIMER_NAMES.WAIT_FOR_FOOD:
		pass
	#they're done eating and are waiting for check
	elif current_timer == FranchiseGlobal.TIMER_NAMES.EATING:
		readyForCheck()
		pass
	elif current_timer == FranchiseGlobal.TIMER_NAMES.CUSTOMER_LEAVING:
		startLeaving(true)

func readyForCheck():
	current_timer = FranchiseGlobal.TIMER_NAMES.CUSTOMER_LEAVING
	clicker.disabled = false
	clicker.text = "READY FOR CHECK"

func startWaitingForFood():
	print(table_num)
	var item : String = "ORDER"
	order_data.onPartyOrdered()
	#body_ref.handPlayerItem(item)
	
	
	current_timer = FranchiseGlobal.TIMER_NAMES.WAIT_FOR_FOOD
	#this timer shouldn't start here, but should instead be stored to be used in a method with the counter
	#timer.start(party_timers[GameConfig.getTimerDictKey(current_timer)])
	#blah
	pass
func playerPickedUpOrder():
	#body_ref.handPlayerItem("ORDER")
	pass
	
func startEating():
	current_timer = FranchiseGlobal.TIMER_NAMES.EATING
	print('eating now')
	#blah
	pass	
#either because paid or dashing
func startLeaving(isDashing : bool = false):
	var tween = create_tween()
	body_ref.clearCustomers()
	cleanUpPartyDELETE()
	self.queue_free()
	
	
func prepareForFood():
	$EventClicker.disabled = false
	$EventClicker.text = "deliver food"
	print("current Timer: ", current_timer)
	current_timer = FranchiseGlobal.TIMER_NAMES.EATING
	
	
	

#when timer expires AND clicker is pressed, increment
@onready var clicker = $EventClicker
func _on_event_clicker_pressed() -> void:
	var reason : FranchiseGlobal.HIGHLIGHT
	match current_timer:
		FranchiseGlobal.TIMER_NAMES.ORDERING:
			#startWaitingForFood()
			reason = FranchiseGlobal.HIGHLIGHT.PICKUP_ORDER
			pass
		FranchiseGlobal.TIMER_NAMES.WAIT_FOR_FOOD:
			#if food in hand:
			reason = FranchiseGlobal.HIGHLIGHT.DELIVER_FOOD
			pass
		FranchiseGlobal.TIMER_NAMES.EATING:
			reason = FranchiseGlobal.HIGHLIGHT.CHECK
			pass
		FranchiseGlobal.TIMER_NAMES.CUSTOMER_LEAVING:
			reason = FranchiseGlobal.HIGHLIGHT.CUSTOMER_LEAVING
			pass
	requestPlayer(reason)
	startAppropriateTimer(current_timer)
	clicker.disabled = true #also disable clicker
	$EventClicker.text = "WAITING"
	pass # Replace with function body.
func startAppropriateTimer(curr_timer : FranchiseGlobal.TIMER_NAMES):
	timer.start(party_timers[GameConfig.getTimerDictKey(current_timer)])
	print(FranchiseGlobal.TIMER_NAMES.keys()[curr_timer])
	
func requestPlayer(reason : FranchiseGlobal.HIGHLIGHT):
	body_ref.requestServer(reason)
	pass
	
func onPlayerArrival():
	match current_timer:
		FranchiseGlobal.TIMER_NAMES.ORDERING:
			pass
		FranchiseGlobal.TIMER_NAMES.WAIT_FOR_FOOD:
			timer.start(party_timers[GameConfig.getTimerDictKey(current_timer)])
			current_timer = FranchiseGlobal.TIMER_NAMES.EATING
			startEating()
		FranchiseGlobal.TIMER_NAMES.CUSTOMER_LEAVING:
			print("leaving now")
			startLeaving(false)
			animateTipNumbersFloating(prepareTip())
			
	print("current timer: ", current_timer)
	
var payment : int
func prepareTip() -> int:
	var base_min = order_data.min_payment
	var base_max = order_data.max_payment
	var health_ratio = party_curr_health / party_max_health
	
	# cap maximum based on curr health
	var adjusted_max = base_min + int((base_max - base_min) * health_ratio)
	
	# if below 40% health, also reduce minimum tip
	var adjusted_min = base_min
	if health_ratio <= 0.4: #less than or equal to 2.0 or 2 full hearts
		adjusted_min = int(base_min * (health_ratio / 0.4))  # Scales from 0 to base_min
	
	adjusted_max = max(adjusted_max, adjusted_min)
	
	payment = randi_range(adjusted_min, adjusted_max)
	return payment

func animateTipNumbersFloating(amount:int):
	var text : String = "$" + str(amount)
	print(text)
	FloatingText.create_floating_text(text, body_ref.global_position, body_ref)
