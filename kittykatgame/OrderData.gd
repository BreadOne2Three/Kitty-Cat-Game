extends Resource
class_name OrderData

#IDs
@export var order_id : int
@export var table_id : int
@export var party_id : FranchiseGlobal.PARTY_TYPE


#times
@export var order_time : float = 4.0 #average order time, does not factor noise or party dispositions
@export var cook_time : float = 5.0
@export var eating_time : float = 10.0
@export var time_spawned : float

#payment
@export var min_payment : int = 0
@export var max_payment : int = 100


@export var patience : float = 40.0
@export var patience_decay_rate : float = 1.5

@export var customer_generates_filth : bool = false
@export_range(0.0, 1.0, .01) var filth_rate : float 
@export var customer_made_mess : bool = false

@export var customer_generates_noise : bool = false
@export var customer_noisiness : float = .5 #percent radius of noise generated, does it effect just nearest table? entire restaurant?
@export_range(0.0, 1.0, .01) var customer_noise_rate: float = .2


@export_range(0.0, 1.0, .05) var refill_rate : float = .5 #the rate at which refills are needed, will likely make it a percent poll
@export var needs_refill : bool = false


@export var party_modifiers : Dictionary = {}


#signals
signal dishGrabbedByPlayer(table_num : int) #player picked up order for table_num
signal requestLeave(without_paying : bool, payment : float) #request party leave with/without paying
signal generateNoise(percent_radius : float, table_location:int) #generate noise radius around table
signal readyToOrder(table_num : int) #party at table_num ready to order
signal dishDoneCooking(table_num : int) #order for table_num finished cooking
signal orderReadyToSubmit #order has been picked up by player and is ready to submit

var current_timer : SceneTreeTimer = null

var patience_modifiers = {}


func addPatienceModifier(source: String, amount : float):
	patience_modifiers[source] = amount



func onTenSecondTimeout():
	
	var without_paying = true
	if deterioratePatience():
		requestLeave.emit(without_paying, 0.0) #leave without paying
		return
	
	needs_refill = doesNeedRefill()
	if customer_generates_filth:
		customer_made_mess = didTheyMakeAMess()
	
	if customer_generates_noise and didTheyMakeANoise():
		generateNoise.emit(customer_noisiness, table_id)
		
	
func didTheyMakeANoise() -> bool:
	return (customer_noise_rate > randf())
func didTheyMakeAMess() -> bool:
	return (filth_rate > randf()) #determine if customer made mess
func doesNeedRefill() -> bool:
	return (refill_rate > randf()+.3) #+30% chance that they don't need refill by default
func deterioratePatience() -> bool:
	patience -= patience_decay_rate
	return patience <= 0





func _start_timer(duration: float, next_status: OrderStatus):
	if current_timer:
		current_timer.timeout.disconnect(_on_timer_completed)
	
	current_timer = Engine.get_main_loop().create_timer(duration)
	current_timer.timeout.connect(_on_timer_completed.bind(next_status), CONNECT_ONE_SHOT)

func _on_timer_completed(next_status: OrderStatus):
	match next_status:
		OrderStatus.PENDING:
			onOrderTimeout()
		OrderStatus.READY:
			onDoneCooking()
		OrderStatus.COMPLETED:
			onFinishedEating()


enum OrderStatus {
	UNSEATED, #CUSTOMER NOT EVEN SEATED
	SEATED, #CUSTOMER SEATED BUT NOT DONE ORDERING
	PENDING, #CUSTOMER READY TO ORDER
	COOKING, #CURRENTLY COOKING DISH
	READY, #DISH COOKED
	DELIVERED, #FOOD DELIVERED
	COMPLETED #FINISHED EATING FOOD, READY FOR CHECK
}
var curr_status : OrderStatus = OrderStatus.UNSEATED

func _init() -> void:
	time_spawned = Time.get_ticks_msec() / 1000.0
	
	#add/parse party modifiers


func onPartySeatedAtTable(table : TableObject):
	table_id = table.getTableNum()
	curr_status = OrderStatus.SEATED
	_start_timer(order_time, OrderStatus.PENDING)
	

func onOrderTimeout():
	curr_status = OrderStatus.PENDING
	readyToOrder.emit(table_id)

#order has been picked up
func onPartyOrdered():
	curr_status = OrderStatus.COOKING
	orderReadyToSubmit.emit()
	
func onOrderSubmitted():
	_start_timer(cook_time, OrderStatus.READY)


func onDoneCooking():
	curr_status = OrderStatus.READY
	dishDoneCooking.emit()
	

func onFoodPickedUp():
	dishGrabbedByPlayer.emit(table_id)
	
func onFoodDelivered():
	curr_status = OrderStatus.DELIVERED
	_start_timer(eating_time, OrderStatus.COMPLETED)


func onFinishedEating() -> float:
	curr_status = OrderStatus.COMPLETED
	var payment : float = randf_range(min_payment, max_payment)
	requestLeave.emit(false, payment)
	return payment
