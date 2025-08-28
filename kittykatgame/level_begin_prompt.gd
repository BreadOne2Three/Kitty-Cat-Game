extends Control

##boolean toggle to determine if it needs popping up in the first place
@export var levelHasPrompt : bool = false
##the level prompt box setting up premise for level
@export var levelPromptText : String = "" 

@export var pointGoal : int = 0

signal gameLoaded()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameLoaded.connect(pauseGame)
	
	if levelHasPrompt:
		showLevelPrompt()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func showLevelPrompt():
	pass

func pauseGame():
	pass
