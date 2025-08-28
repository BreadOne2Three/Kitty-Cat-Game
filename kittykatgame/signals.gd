extends Node


signal timerFinished(event: FranchiseGlobal.TIMER_NAMES, table_num: int)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timerFinished.connect(timerWentOffFor)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func timerWentOffFor(event:FranchiseGlobal.TIMER_NAMES, table_num: int):
	
	pass
	
