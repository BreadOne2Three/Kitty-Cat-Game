extends Node2D

@onready var sprite = $Sprite2D
@onready var area = $Area2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hovering:
		if Input.is_action_just_pressed("click") and player_nearby:
			onOrderSubmitted()
	pass
	
var animation_frames: Array[Rect2]
var tween: Tween
var tween_length : float = .2
var loop_count : int = 0
var target_loops : int = 3

func onOrderSubmitted():
	#play animation
	if not tween:
		tween = create_tween()
	
	loop_count = 0
	animateLoop()


func setPlayerNearby(status:bool):
	player_nearby = status
	
func animateLoop():
	tween = create_tween()
	tween.set_loops(4)
	tween.tween_method(sprite.set_frame, 0, 3, tween_length)
	tween.tween_callback(on_sequence_complete)

func on_sequence_complete():
	loop_count += 1
	if loop_count < target_loops:
		animateLoop()  # Start next loop
	else:
		_on_area_2d_mouse_exited()
func getServePos()->Node2D:
	return $Area2D/CollisionShape2D

signal startCooking(table_num:int)
func interact(table_num: int):
	onOrderSubmitted()
	startCooking.emit(table_num)
	pass

var hovering : bool = false
var player_nearby : bool = false
func _on_area_2d_mouse_entered() -> void:
	hovering = true
	sprite.frame = 1
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	hovering = false
	sprite.frame = 0
	pass # Replace with function body.
