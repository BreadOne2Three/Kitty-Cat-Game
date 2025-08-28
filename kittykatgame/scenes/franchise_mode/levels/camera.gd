extends Camera2D

enum CAMERA_STATE {ENTRANCE, DINING_MAIN, SHOP, DINING_SOUTH, BATHROOM, KITCHEN}

var curr_state = CAMERA_STATE.ENTRANCE


##dictionary with key values accessing camera locations
@onready var state_positions = {
	CAMERA_STATE.ENTRANCE: $Positions/EntrancePosition.global_position,
	CAMERA_STATE.DINING_MAIN: $Positions/DiningMainPosition.global_position,
	CAMERA_STATE.SHOP: $Positions/ShopPosition.global_position,
	CAMERA_STATE.DINING_SOUTH: $Positions/DiningSouthPosition.global_position,
	CAMERA_STATE.KITCHEN: $Positions/KitchenPosition.global_position, 
	CAMERA_STATE.BATHROOM: $Positions/BathroomPosition.global_position
}


##adjacency list of valid relationships
var adjacency_relationship = {
	CAMERA_STATE.ENTRANCE: [CAMERA_STATE.DINING_MAIN, CAMERA_STATE.SHOP],
	CAMERA_STATE.DINING_MAIN: [CAMERA_STATE.ENTRANCE, CAMERA_STATE.DINING_SOUTH, CAMERA_STATE.KITCHEN, CAMERA_STATE.BATHROOM],
	CAMERA_STATE.SHOP: [CAMERA_STATE.ENTRANCE],
	CAMERA_STATE.DINING_SOUTH: [CAMERA_STATE.DINING_MAIN],
	CAMERA_STATE.BATHROOM: [CAMERA_STATE.DINING_MAIN],
	CAMERA_STATE.KITCHEN: [CAMERA_STATE.DINING_MAIN]
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("right") and curr_state != CAMERA_STATE.RIGHT:
		#_on_right_arrow_pressed_arrow()
	#if Input.is_action_just_pressed("left") and curr_state != CAMERA_STATE.LEFT:
		#_on_left_arrow_pressed_arrow()
	###second part of dining room
	#if Input.is_action_just_pressed("down") and curr_state == CAMERA_STATE.RIGHT:
		#pass
	###camera is in shop
	#if Input.is_action_just_pressed("down") and curr_state == CAMERA_STATE.SHOP:
		#pass
	###go to shop
	#if Input.is_action_just_pressed("up") and curr_state == CAMERA_STATE.LEFT:
		#pass
	###move from bottom right to top right
	#if Input.is_action_just_pressed("up") and curr_state == CAMERA_STATE.BOTTOM_RIGHT:
		#pass
	
	pass



func _on_left_arrow_pressed_arrow() -> void:
	var tween = create_tween()
	tween.tween_property(self, 'global_position',  state_positions[CAMERA_STATE.ENTRANCE], .1)
		
	#tween stuff
	curr_state = CAMERA_STATE.ENTRANCE


func _on_right_arrow_pressed_arrow() -> void:
	var tween = create_tween()
	tween.tween_property(self, 'global_position', state_positions[CAMERA_STATE.DINING_MAIN], .1)
		
	#tween stuff
	curr_state = CAMERA_STATE.DINING_MAIN



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Party and FranchiseGlobal.is_dragging:
		_on_right_arrow_pressed_arrow()
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	_on_right_arrow_pressed_arrow()
	pass # Replace with function body.
