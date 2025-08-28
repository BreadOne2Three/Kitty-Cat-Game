extends Node2D
class_name Chair

@onready var sprite = $Sprite2D
@onready var collision = $MouseCollision/CollisionShape2D

var active_color = FranchiseGlobal.PARTY_COLOR.YELLOW
var color_combo:int = 1

signal mouse_entered_chair

enum seat_type {RAINBOW, PLASTIC, JAPANESE, ROYAL, WOODEN, PUSHED_IN}
enum rainbow_colors {RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET, PLAIN}

func _ready() -> void:
	sprite.frame_coords = Vector2i(rainbow_colors.PLAIN, seat_type.RAINBOW)
	

func customerSeated(color:FranchiseGlobal.PARTY_COLOR):
	#if the customer's color == the active color, increment
	if active_color == color:
		color_combo += 1
	#else, reset it to the new one
	else:
		color_combo = 1
		active_color = color
		
func chairPos() -> Vector2:
	return $CustomerSeatNode.global_position

func changeSprite(color:rainbow_colors, type:seat_type):
	sprite.frame_coords = Vector2i(color, type)
	pass


func _on_mouse_collision_mouse_entered() -> void:
	mouse_entered_chair.emit()

func enableCollision():
	collision.disabled = false
func disableCollision():
	collision.disabled = true
