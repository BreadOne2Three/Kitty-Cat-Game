extends Control

enum state {GREEN_DEFAULT, GREEN_HOVER, GREEN_CLICK, FADED_DEFAULT, FADED_HOVER, FADED_PRESS, YELLOW_DEFAULT, YELLOW_HOVER, YELLOW_CLICK}
@onready var sprite = $Sprite2D
@export_range(0, 2, 1) var kind : int = 0
@export var flip : bool = false
signal pressed_arrow
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = 0 + (kind * 3)

	sprite.flip_v = flip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_button_mouse_entered() -> void:
	sprite.frame = 1 + (kind * 3) 



func toggle_visibility(on:bool = true):
	self.visible = on
	
func _on_button_pressed() -> void:
	sprite.frame = 2 + (kind * 3)
	pressed_arrow.emit()
	

func _on_button_mouse_exited() -> void:
	sprite.frame = 0 + (kind * 3)
