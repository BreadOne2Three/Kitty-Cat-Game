extends Node

signal currentLevelChanged

#this script is exclusively for handling dynamic values (noise, balk point modifiers, etc.)

# runtime state that changes during gameplay
var curr_time_of_day: FranchiseGlobal.TimeOfDay = FranchiseGlobal.TimeOfDay.NORMAL
var curr_service_perception : FranchiseGlobal.SERVICE_SPEED = FranchiseGlobal.SERVICE_SPEED.NORMAL

var restaurant_amenities : Dictionary = {}

##Ranges from .5 to 2.0. 1.0 is neutral, .5 is pristine, and 2.0 is nasty(fail health inspection?)
var restaurant_cleanliness: float = 1.0
##Ranges from 0.0 (dead) to 2.0 (unbearable)
var restaurant_noise_level: float = 0.5

##Running Tally/Average of customer wait times
##this is the time from entrance to seating for factoring balk point
var average_service_time: float = 15.0

##received from party spawner, keeps track of line for balk formula
var parties_in_queue: int = 0

##same as above, this has half the weight of those in queue, the reason it has any weight at all is because
#a full restaurant means less seating which equals more waiting
var seated_parties: int = 0

##additionally used for the balk formula, if there are empty seats, heavily helps balk point
#this will need balancing to prevent players just leaving tables empty while the queue fills
var total_tables : int = 0

# performance tracking
var recent_service_times: Array[float] = []



var LengthOfDay: float = 1440.0
var LengthOfUpdates : float = 10.0





##Ranges from 1-10 (.5 to 5 star restaurant -- may add a prestige mechanic but that can wait)
var current_level: int = 1
var max_level : int = 10

var restaurant_time_rush : FranchiseGlobal.TimeOfDay = FranchiseGlobal.TimeOfDay.NORMAL



func levelUp():
	current_level += 1
	currentLevelChanged.emit()
