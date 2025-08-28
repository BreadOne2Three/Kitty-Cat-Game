extends Node


@export var counter_ref : Counter = null #contains references to both the order_submission and order_pickup
@export var table_array : Node2D = null
@export var customerSpawner : PartySpawner = null
@export var player_ref : Player = null
var table_ref : Dictionary = {}

var active_orders: Dictionary = {
	
}
#^ "order_id" is is the customer_id which serves as the key 



#signal dishGrabbedByPlayer(table_num : int) #player picked up order for table_num
#signal requestLeave(without_paying : bool, payment : float) #request party leave with/without paying
#signal generateNoise(percent_radius : float) #generate noise radius around table
#signal readyToOrder(table_num : int) #party at table_num ready to order
#signal dishDoneCooking(table_num : int) #order for table_num finished cooking
#signal orderReadyToSubmit #order has been picked up by player and is ready to submit


#customer spawned in
func addOrder(order: OrderData):
	
	active_orders[order.order_id] = order
	order.dishGrabbedByPlayer.connect(playerGrabbedDish)
	order.dishDoneCooking.connect(spawnDishFor)
	order.generateNoise.connect(generateNoise)
	order.orderReadyToSubmit.connect(readyToSubmitOrder)
#signal dishGrabbedByPlayer(table_num : int) #player picked up order for table_num
#signal requestLeave(without_paying : bool, payment : float) #request party leave with/without paying
#signal generateNoise(percent_radius : float) #generate noise radius around table
#signal readyToOrder(table_num : int) #party at table_num ready to order
#signal dishDoneCooking(table_num : int) #order for table_num finished cooking
#signal orderReadyToSubmit #order has been picked up by player and is ready to submit




func _ready() -> void:
	for child in table_array.get_children():
		table_ref[child.getTableNum()] = child
		child.requestPlayer.connect(request_player_to_object)
		child.user_has_ticket.connect(readyToSubmitOrder)
		#child._hand_player_object
	counter_ref.requestPlayer.connect(request_player_to_object)
	counter_ref.hand_player_dish.connect(playerGrabbedDish)
	counter_ref.player_ref = player_ref
	counter_ref.foodReadyFor.connect(readyToDeliverFood)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func request_player_to_object(reason: FranchiseGlobal.HIGHLIGHT, object: Node2D):
	#var target_object : Node2D = object
	#if object is TableObject:
		#target_object = object.getTableServePos()
	player_ref.queueAction(reason, object)
	
	
func hand_player_object(item_type:String, table_num:int):
	player_ref.addItemToInventory(item_type, table_num)
#table_num is to be made clickable to pick up order
func readyToOrder(table_num : int):
	pass

#player has order in hand, ready to submit (orderReadyToSubmit())
func readyToSubmitOrder():
	counter_ref.userHasTicket()
func readyToDeliverFood(table_num: int):
	table_ref[table_num].prepareTableForFood()
	pass

#generateNoise()
func generateNoise(percent_radius:float, table_num : int):
	#table_num gets a circle where the radius-fullness is percent_radius/1.0
	var table = table_ref[table_num]
	
	pass

#dishGrabbedByPlayer()
#CONNECTED
#TODO, VERIFY CONNECTION/WORKING
func playerGrabbedDish(table_num: int):
	#player_ref adds dish
	player_ref.addItemToInventory("FOOD", table_num)
	
	pass
	
#on dishDoneCooking
#CONNECTED
#TODO, VERIFY CONNECTION/WORKING
func spawnDishFor(table_num : int):
	#counter logic
	counter_ref.spawn_dish(table_num)
	pass
	
