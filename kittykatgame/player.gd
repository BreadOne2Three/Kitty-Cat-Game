extends CharacterBody2D
class_name Player

var queued_mark = preload("res://assets/queued_action.png")

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var doing_tasks : bool = false
const SPEED := 750
signal queue_empty

var action_queue : Array[Dictionary] = []
var inventory_arr : Array[Dictionary] = []
var DECAL_OFFSET = 32
var STOP_DISTANCE : float = 5.0
var arrived : bool = false
var decal_sprites: Array[Sprite2D] = []
var curr_action = null

func _ready() -> void:
	nav_agent.navigation_finished.connect(_on_navigation_finished)
	pass

func _process(delta: float) -> void:
	# only start next task if we're not currently doing one
	if not doing_tasks and not action_queue.is_empty():
		start_next_task()

func start_next_task():
	if action_queue.is_empty():
		doing_tasks = false
		queue_empty.emit()
		return
	doing_tasks = true
	curr_action = action_queue[0]  # peek at next action, don't pop yet
	setNavAgent(curr_action["interact_pos"])

func _physics_process(_delta: float) -> void:
	if doing_tasks and !nav_agent.is_navigation_finished():
		var target_position := nav_agent.get_next_path_position()
		var direction = global_position.direction_to(target_position)

		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func queueAction(type : FranchiseGlobal.HIGHLIGHT, from_body : Node2D):
	var queue_pos = from_body.global_position

	# calculate marker offset NOTE: NOT WORKING
	var actions_at_pos = action_queue.filter(func(a): return a["interact_pos"] == from_body.global_position)
	queue_pos.x += actions_at_pos.size() * DECAL_OFFSET
	
	# prevent collision
	for action in action_queue:
		if action["queue_pos"] == queue_pos:
			queue_pos.x += 32
	
	action_queue.append({
		"queue_pos": queue_pos,
		"interact_pos": from_body.getServePos().global_position,
		"action_type": type,
		"requires_item": GameConfig.doesThisRequireItem(type),
		"node_ref": from_body
	})
	
	spawn_queue_decal(queue_pos)
	
	# if not currently doing a task, start immediately
	if not doing_tasks:
		start_next_task()

func spawn_queue_decal(queue_pos : Vector2):
	var sprite = Sprite2D.new()
	sprite.texture = queued_mark
	sprite.global_position = queue_pos
	$QueuedMarks.add_child(sprite)
	decal_sprites.append(sprite) 
	
func removeCompletedDecal():
	if not decal_sprites.is_empty():
		var sprite = decal_sprites.pop_front()
		sprite.queue_free()

func onArrivalToQueuedAction():
	if arrived: 
		if action_queue.is_empty():
			doing_tasks = false
			return

		var action = action_queue.pop_front()  # now we actually remove it
		curr_action = action
		interactWithNodeRef(action["node_ref"], action["action_type"])

		# check if this action gives the player an item
		var item = GameConfig.doesThisReturnItem(action["action_type"])
		if item != "NOTHING": #if this gives an item, add it to inventory
			var table_num = 0
			if action["node_ref"].has_method("getTableNum"):
				table_num = action["node_ref"].getTableNum()
			addItemToInventory(item, table_num)
		elif doesPlayerHaveAppropriateItem(action, inventory_arr):
			doAction(action, inventory_arr)
		else:
			print("Player doesn't have required item for action: ", action["requires_item"])
		
		removeCompletedDecal()
		
		# finish current task and do next one if possible
		doing_tasks = false
		
		if not action_queue.is_empty():
			start_next_task()
		else:
			queue_empty.emit()
		arrived = false
		$NavigationAgent2D/Area2D.monitoring = false


func interactWithNodeRef(node_ref : Node2D, action: FranchiseGlobal.HIGHLIGHT):
	if node_ref is TableObject:
		match action:
			FranchiseGlobal.HIGHLIGHT.PICKUP_ORDER:
				node_ref.takeOrder()
	pass


func doesPlayerHaveAppropriateItem(action : Dictionary, inventory: Array[Dictionary]) -> bool:
	var req_item = action["requires_item"]
	if req_item == "NOTHING":
		return true
		
	for item in inventory:
		if item["item_type"] == req_item:
			if action["action_type"] == FranchiseGlobal.HIGHLIGHT.DELIVER_FOOD:
				return action["node_ref"].getTableNum() == item["table_num"]
			else:
				return true
	return false

func popInventoryItem(inventory : Array[Dictionary], item: String) -> Dictionary:
	for i in range(inventory.size()):
		if inventory[i]["item_type"] == item:
			return inventory.pop_at(i)
	return {}
func removeInventoryItemIfEqual(index:int, item_type: String) -> Dictionary:
	if inventory_arr[index]["item_type"] == item_type:
		return inventory_arr.pop_at(index)
	return {}
func doAction(action : Dictionary, inventory : Array[Dictionary]):
	var required_item = action["requires_item"]
	var item = null
	if required_item != "NOTHING":
		item = popInventoryItem(inventory, required_item)
		if item == {}:
			print("Failed to find required item: ", required_item)
			return
		print("Used item: ", item)
	
	# perform interaction
	if action["node_ref"].has_method("interact") and item != null:
		action["node_ref"].interact(item["table_num"])

func addItemToInventory(item: String, table_num : int = 0):
	for aitem in inventory_arr:
		if aitem["item_type"] == item and aitem["table_num"] == table_num:
			return #can't have duplicates
	if len(inventory_arr) < 2:
		inventory_arr.append({
			"item_type": item,
			"table_num": table_num
		})
		print("Added to inventory: ", item, " for table: ", table_num)
		
var navigation_completed = false

func setNavAgent(pos : Vector2):
	arrived = false
	$NavigationAgent2D/Area2D.monitoring = false
	$NavigationAgent2D/Area2D/CollisionShape2D.disabled = true
	navigation_completed = false
	nav_agent.target_position = pos

func _on_navigation_finished() -> void:
	if navigation_completed:
		return
	navigation_completed = true
	
	print("Navigation finished - arrived at target")
	arrived = true
	$NavigationAgent2D/Area2D.monitoring = true
	$NavigationAgent2D/Area2D/CollisionShape2D.disabled = false
	onArrivalToQueuedAction()
	
func getInventory() -> Array[Dictionary]:
	return inventory_arr

# quick clear button for debugging
func clearQueue():
	action_queue.clear()
	for sprite in decal_sprites:
		sprite.queue_free()
	decal_sprites.clear()
	doing_tasks = false
	curr_action = null


func _on_queue_empty() -> void:
	navigation_completed = true
	pass # Replace with function body.
