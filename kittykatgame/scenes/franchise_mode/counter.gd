extends Node2D
class_name Counter

var curr_dishes : int = 0 #number of dishes on the counter, used for spawning
var dish_spawn_points = []
var dish_point_data : Dictionary = {}
@onready var player_ref : Player = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for child in $DishesSpawn.get_children():
		dish_spawn_points.append(child)
		child = child as Dish
		child.deleteDish.connect(_on_player_arrival)
		child.button_pressed.connect(_on_dish_selected)
		
		
		dish_point_data[child] = {
			"active": false,
			"table_num": 0
		}
	displayTrueDishes()
	

func displayTrueDishes():
	for dish in dish_spawn_points:
		var dish_data = dish_point_data[dish]
		if dish_data["active"]:
			dish.displayDish(dish_data["table_num"])
		else:
			dish.hideDish()

func spawn_dish(table_num: int) -> bool:
	# is table_num currently in use?
	for dish in dish_spawn_points:
		var dish_data = dish_point_data[dish]
		if dish_data["active"] and dish_data["table_num"] == table_num:
			print("dish: ", dish_data, " is active")
			return false # SHOULD NOT HAPPEN -- FLAG IT
			#TODO ADD A FLAG ^
	# find first empty slot
	for dish in dish_spawn_points:
		var dish_data = dish_point_data[dish]
		if !dish_data["active"]:
			dish_point_data[dish] = {
				"active": true,
				"table_num": table_num
			}
			dish.displayDish(table_num)
			return true
	return false #should not happen unless dishes are full but should not happen as there are x spawns for x tablesFLAG IT
	#TODO ADD A FLAG FOR DEBUG^
func remove_dish(table_num: int):
	print("deleting dish: ", table_num)
	for dish in dish_point_data:
		if dish.getDishNum() == table_num:
			dish_point_data[dish] = {
				"active": false,
				"table_num": 0
			}
			displayTrueDishes()
			return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func userHasTicket():
	$OrderSubmission/SubmitOrder.disabled = false
	$OrderSubmission/SubmitOrder.visible = true
	pass

#signal requestPlayer(object: Dish)x
signal foodReadyFor(table:int)
func _on_dish_selected(object: Dish) -> void:
	var table_num = object.getDishNum()
	#remove_dish(table_num)
	requestPlayer.emit(FranchiseGlobal.HIGHLIGHT.PICKUP_FOOD, object)
	foodReadyFor.emit(table_num)
	pass # Replace with function body.

signal hand_player_dish(dish_num : int)
func _on_player_arrival(dish_num: int):
	remove_dish(dish_num)
	hand_player_dish.emit(dish_num)
	pass
signal requestPlayer(reason : FranchiseGlobal.HIGHLIGHT, object: Node2D)
#signal request_player(object: Node2D)
func _on_submit_order_pressed() -> void:
	#var inventory = player_ref.getInventory()
			##inventory_arr.append({
			##"item_type": item,
			##"table_num": table_num
		##})
	#for item in inventory:
		#if item["item_type"] == "ORDER":
	requestPlayer.emit(FranchiseGlobal.HIGHLIGHT.SUBMIT_ORDER, $OrderSubmission/OrderSubmit)

signal start_cooking(table_num : int)
func handOverOrder():
	var inventory = player_ref.getInventory()
	for i in range(inventory.size()):
		var value : Dictionary
		value = player_ref.removeInventoryItemIfEqual(i, "ORDER")
		if value != {}:
			start_cooking.emit(value["table_num"])

func order_completed():
	pass


func _on_order_submit_start_cooking(table_num: int) -> void:
	spawn_dish(table_num)
	pass # Replace with function body.
