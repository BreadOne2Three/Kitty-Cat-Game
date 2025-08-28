extends Node
#static values for loading
class_name GameConfig

#patience drains at default rate * factors
#customer/party dispositions
const dispositions : Dictionary = {
	"PATIENT": {
	"display_name": "Old Regular",
	"base_patience": 75.0,
	"patience_drain_rate": 0.5,
	"stage_timeouts": {
	  "ordering": 10.0,
	  "wait_for_food": 12.0,
	  "eating": 10.0,
	  "dash_wait": 40.0
	},
	"environmental_multipliers": {
	  "restaurant_dirtiness": 1.8,
	  "noise_level": 1.0,
	  "baby_crying": 1.3,
	  "other_customers_leaving": 2.5
	},
	"tip_range": [50, 250],
	"balk_stats": {
	  "max_wait": 75.0,
	  "check_intervals": 10.0,
	  "base_penalty": .5,
	  "per_people_ahead_penalty": 1.0,
	  },
	"special_behaviors": ["requests_refills_frequently", "slow_eater"]
  },

  "NORMAL": {
	"display_name": "Young Regular",
	"base_patience": 50.0,
	"patience_drain_rate": .6,
	"stage_timeouts": {
	  "ordering": 7.0,
	  "wait_for_food": 10.0,
	  "eating": 7.5,
	  "dash_wait": 30.0
	},
	"environmental_multipliers": {
	  "restaurant_dirtiness": 1.3,
	  "noise_level": 1.3,
	  "baby_crying": 1.8,
	  "other_customers_leaving": 2.0
	},
	"tip_range": [100, 400],
	"balk_stats": {
	  "max_wait": 60.0, 
	  "check_intervals": 5.0,
	  "base_penalty": .75,
	  "people_ahead_penalty": 2.0
	},
	"special_behaviors": ["none"]
  }
}

#dash wait is the time they're willing to wait for the check before dashing
#this will need balancing, but if players are focusing on serving customers, it shouldn't be an issue
const timer_keys = {
	FranchiseGlobal.TIMER_NAMES.ORDERING: "ordering", 
	FranchiseGlobal.TIMER_NAMES.WAIT_FOR_FOOD: "wait_for_food", 
	FranchiseGlobal.TIMER_NAMES.EATING: "eating", 
	FranchiseGlobal.TIMER_NAMES.CUSTOMER_LEAVING: "dash_wait"
}

const disposition_keys = {
	FranchiseGlobal.PARTY_TYPE.PATIENT: "PATIENT",
	FranchiseGlobal.PARTY_TYPE.NORMAL: "NORMAL",
	FranchiseGlobal.PARTY_TYPE.IMPATIENT: "IMPATIENT",
	FranchiseGlobal.PARTY_TYPE.CRITIC: "CRITIC"
}

static func getTimerDictKey(name : FranchiseGlobal.TIMER_NAMES):
	return timer_keys[name]



#take special behavior name and have a dictionary with 'key' (value it influences) and the amount (floating multiple)
#so just access it like temp = dispositions[special_behaviors]
#for item in temp, var temp2 = special_behaviors_list[item]
#then temp2 will be {"key", value) which you can access with 
# var effects = temp2.keys()
# var amount = temp2.values() or something like that
#normal is the most average customer, so i cant think of any traits they would have??
var special_behaviors_list = {
	"requests_refills_frequently": {"thirst": 2.0},
	"slow_eater": {"eating": .5}
}

##how time of day effects spawn rates
const time_of_day_keys = {
	FranchiseGlobal.TimeOfDay.OPEN: .2,
	FranchiseGlobal.TimeOfDay.BREAKFAST_RUSH: .66,
	FranchiseGlobal.TimeOfDay.NORMAL : .5,
	FranchiseGlobal.TimeOfDay.LUNCH_RUSH : .75,
	FranchiseGlobal.TimeOfDay.AFTERNOON_LULL: .3,
	FranchiseGlobal.TimeOfDay.DINNER_RUSH : .99,
	FranchiseGlobal.TimeOfDay.CLOSING_TIME : .2,
	FranchiseGlobal.TimeOfDay.CLOSED : .0
}

##greatly punishes slow service but lightly rewards fast service
#extremely fast should be virtually impossible to achieve without being something like a speedrunner who has optimized the game
const service_perception = {
	FranchiseGlobal.SERVICE_SPEED.EXTREMELY_SLOW: .05,
	FranchiseGlobal.SERVICE_SPEED.SLOW : .025,
	FranchiseGlobal.SERVICE_SPEED.NORMAL : .005,
	FranchiseGlobal.SERVICE_SPEED.FAST : -.075,
	FranchiseGlobal.SERVICE_SPEED.EXTREMELY_FAST : -.050
}


var refill_default_wait : float = 5.0

#%percentage split of customer types

#gotta decide on balance like picky vs impatient customers
const restaurant_rating_customer_types = {
	1: {FranchiseGlobal.PARTY_TYPE.PATIENT:.60, FranchiseGlobal.PARTY_TYPE.NORMAL: .40},
	2: {FranchiseGlobal.PARTY_TYPE.NORMAL: .60, FranchiseGlobal.PARTY_TYPE.PATIENT:.20, FranchiseGlobal.PARTY_TYPE.PICKY: .20},
	3: {FranchiseGlobal.PARTY_TYPE.NORMAL: .40, FranchiseGlobal.PARTY_TYPE.PATIENT: .20, FranchiseGlobal.PARTY_TYPE.PICKY: .20, FranchiseGlobal.PARTY_TYPE.IMPATIENT: .20},
	4: {},
	5: {},
	6: {},
	7: {},
	8: {},
	9: {},
	10: {}
}



const restaurant_upgrades = {
	"table_small_seats_upgrade": {
		"name": "Small Table Seating Upgrade",
		"description": "Upgrade Max Seating Size",
		"cost": 100.00,
		"incrementing_rate": 1.5,
		"placement_size": Vector2i(2,2),
		"valid_surfaces": ["ground"]
		},
	"table_size_upgrade": {
		"name": "Small Table Size Upgrade",
		"description": "Increase the size of the table to accomodate more chairs",
		"cost": 500.00,
		"incrementing_rate": 2.25,
		"placement_size": Vector2i(3, 3),
		"valid_surfaces": ["ground"]
	},
	"window_small": {},
	"window_large": {},
	"host_counter": {},
	"":{}
}

#enum TimeOfDay {OPEN, BREAKFAST_RUSH, NORMAL, LUNCH_RUSH, DINNER_RUSH, CLOSING_TIME}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#enum HIGHLIGHT {WORLD, TABLE, SUBMIT_ORDER, WATER, PICKUP_ORDER, DELIVER_FOOD, DELIVER_WATER, CHECK, DIRTY_DISHES, DISHES_TRAY, MOP, MOP_FLOOR, BABY_SEAT, DELIVER_BABY_SEAT}
static func doesThisRequireItem(Interaction : FranchiseGlobal.HIGHLIGHT) -> String:
	match Interaction:
		FranchiseGlobal.HIGHLIGHT.SUBMIT_ORDER:
			return "ORDER"
		FranchiseGlobal.HIGHLIGHT.DELIVER_FOOD:
			return "FOOD"
		FranchiseGlobal.HIGHLIGHT.DISHES_TRAY:
			return "DIRTY_DISHES"
		FranchiseGlobal.HIGHLIGHT.MOP_FLOOR:
			return "MOP"
		FranchiseGlobal.HIGHLIGHT.DELIVER_WATER:
			return "WATER"
		FranchiseGlobal.HIGHLIGHT.DELIVER_BABY_SEAT:
			return "BABY_SEAT"
		_:
			return "NOTHING"
static func doesThisReturnItem(Interaction : FranchiseGlobal.HIGHLIGHT) -> String:
	match Interaction:
		FranchiseGlobal.HIGHLIGHT.WATER:
			return "WATER"
		FranchiseGlobal.HIGHLIGHT.PICKUP_ORDER:
			return "ORDER"
		FranchiseGlobal.HIGHLIGHT.PICKUP_FOOD:
			return "FOOD"
		FranchiseGlobal.HIGHLIGHT.DIRTY_DISHES:
			return "DIRTY_DISHES"
		FranchiseGlobal.HIGHLIGHT.MOP:
			return "MOP"
		FranchiseGlobal.HIGHLIGHT.BABY_SEAT:
			return "BABY_SEAT"
		_:
			return "NOTHING"
	
static func calculateServiceSpeed(average_speed : float) -> float:
	if average_speed < 7.5:
		return service_perception[FranchiseGlobal.SERVICE_SPEED.EXTREMELY_FAST]
	elif average_speed < 10.0:
		return service_perception[FranchiseGlobal.SERVICE_SPEED.FAST]
	elif average_speed < 15.0:
		return service_perception[FranchiseGlobal.SERVICE_SPEED.NORMAL]
	elif average_speed < 20.0:
		return service_perception[FranchiseGlobal.SERVICE_SPEED.SLOW]
	else:
		return service_perception[FranchiseGlobal.SERVICE_SPEED.EXTREMELY_SLOW]
	

static func getTimeOfDayWeight(key : FranchiseGlobal.TimeOfDay) -> float:
	return time_of_day_keys[key]
	
static func calculateTimeOfDay(time_of_day_elapsed: float) -> FranchiseGlobal.TimeOfDay:
	var percent = fmod((1.0 - (time_of_day_elapsed / FranchiseGlobal.length_of_day) + 0.21), 1.0)
	
	if percent < 0.25:
		return FranchiseGlobal.TimeOfDay.CLOSED
	elif percent < 0.30:
		return FranchiseGlobal.TimeOfDay.OPEN
	elif percent < 0.42:
		return FranchiseGlobal.TimeOfDay.BREAKFAST_RUSH
	elif percent < 0.50:
		return FranchiseGlobal.TimeOfDay.NORMAL
	elif percent < 0.60:
		return FranchiseGlobal.TimeOfDay.LUNCH_RUSH
	elif percent < 0.71:
		return FranchiseGlobal.TimeOfDay.AFTERNOON_LULL
	elif percent < 0.83:
		return FranchiseGlobal.TimeOfDay.DINNER_RUSH
	elif percent < 0.91:
		return FranchiseGlobal.TimeOfDay.CLOSING_TIME
	else:
		return FranchiseGlobal.TimeOfDay.CLOSED


static func getDispositionTimers(disposition : FranchiseGlobal.PARTY_TYPE) -> Dictionary:
	var temp : Dictionary = dispositions[disposition_keys[disposition]]
	return temp["stage_timeouts"]

static func getRestaurantLevelCustomers(rating : int) -> Dictionary:
	return restaurant_rating_customer_types[rating]
