extends CharacterBody2D


@onready var player_texture := $cat
@onready var raycast_collision := $CollisionRaycast
@export var raycast_length := 22
@export var movement_length := 32
@export var movement_speed := 8
var curr_move := 0

var moving := false

func _ready() -> void:
	if player_texture == null:
		#simple debug texture to default to
		player_texture.texture = "res://assets/ooeeaa.jpeg"
	pass
	
func _physics_process(delta: float) -> void:
	
	
	
	velocity = processMovement()
	if (moving):
		isMoving()
	
	
	
	move_and_slide()
	pass
	

func processMovement() -> Vector2:
	#handle user inputs
	var user_input : Vector2
	user_input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	user_input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	rotateRaycast(user_input)
	
	if (user_input != Vector2(0,0)):
		moving = true
	#else:
		#isNotMoving()
	return user_input
	
func rotateRaycast(dir: Vector2):
	var x = sign(dir.x)
	if (x == 1):
		raycast_collision.rotation_degrees = -90
	elif (x == 0):
		var y = sign(dir.y)
		if (y == -1):
			raycast_collision.rotation_degrees = -180
		elif (y == 0):
			return
		else:
			raycast_collision.rotation_degrees = 0
	else:
		raycast_collision.rotation_degrees = 90
	return


#improved readability for these functions, otherwise player is just orienting themselves
func isMoving():
	print('moving')
	raycast_collision.monitoring = true
	
func isNotMoving():
	curr_move = 0
	raycast_collision.monitoring = false

func didICollide():
	var collide = raycast_collision.get_world_2d().space
	pass
	
