extends CharacterBody2D

enum movementDirection{LEFT, UPLEFT, UP, UPRIGHT, RIGHT, DOWNRIGHT, DOWN, DOWNLEFT}
enum movementStatus{MOVING, IDLE}

var playerDir : movementDirection = movementDirection.DOWN
var playerMoveStatus : movementStatus = movementStatus.IDLE

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass
	
	
	
func handle_movement() -> Vector2:
	var user_input : Vector2
	user_input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	user_input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	#determine movement direction
	determineOrientation(user_input)
	#and change sprite
	changeSprite()
	
	return user_input

func determineOrientation(direction: Vector2):
	var xSign = sign(direction.x)
	var ySign = sign(direction.y)
	
	#going right
	if (xSign == 1):
		playerMoveStatus = movementStatus.MOVING
		#going down-right
		if (ySign == 1):
			playerDir = movementDirection.DOWNRIGHT
		#still just going right
		elif (ySign == 0):
			playerDir = movementDirection.RIGHT
		#going up right
		else:
			playerDir = movementDirection.UPRIGHT
	#idle horizontal movement
	elif (xSign == 0):
		if (ySign == 0):
			playerMoveStatus = movementStatus.IDLE
		else:
			playerMoveStatus = movementStatus.MOVING
			if (ySign == 1):
				playerDir = movementDirection.DOWN
			else:
				playerDir = movementDirection.UP
	#going left
	else:
		playerMoveStatus = movementStatus.MOVING
		if (ySign == 1):
			playerDir = movementDirection.DOWNLEFT
		elif (ySign == 0):
			playerDir = movementDirection.LEFT
		else:
			playerDir = movementDirection.UPLEFT
	pass
	
func changeSprite():
	pass
