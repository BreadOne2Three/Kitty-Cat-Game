extends Control

var time_in_day : float = 1440.0

@onready var timer = $TimerForDay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(time_in_day)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TimeOfDay.text = timer.time_left/1440.0
	
	$RestaurantConditions.text
	
	$debug_stats.text
	pass
