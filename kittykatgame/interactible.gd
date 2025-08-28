# Interactable.gd
extends Node2D
class_name Interactable

signal interaction_attempted(interactable: Interactable, player: Player)
signal interaction_completed(interactable: Interactable, player: Player)

enum InteractionType {
	PICKUP,      # orders, dirty dishes
	SUBMIT,      # order sheets to chef
	DELIVER,     # food to customers
	CLEAN,       # tables, dishes
	USE          
}

@export var interaction_type: InteractionType
@export var interaction_time: float = 0.0  # 0 = instant
@export var requires_item: bool = false
@export var required_item_type: String = ""
@export var is_enabled: bool = true

var current_interaction_data: Dictionary = {}
signal _interaction_requested(interactible : Interactable)
func _process(delta: float) -> void:
	if hovering:
		if Input.is_action_just_pressed("click"):
			_interaction_requested.emit(self)
			
func onArrival(player : Player):
	pass
func can_interact(player: Player) -> bool:
	if not is_enabled:
		return false
	
	# check if player has required item
	if requires_item and not player.inventory.has_item_type(required_item_type):
		return false

	return _custom_interaction_check(player)

func interact(player: Player):
	print('interacting with: ', player)
	if not can_interact(player):
		return false
	interaction_attempted.emit(self, player)
	
	if interaction_time > 0:
		_start_timed_interaction(player)
	else:
		_execute_interaction(player)
	return true

# function for overriding possibly
func _custom_interaction_check(player: Player) -> bool:
	return true

func _execute_interaction(player: Player):
	interaction_completed.emit(self, player)

func _start_timed_interaction(player: Player):
	player.start_interaction(self, interaction_time)

var hovering : bool = false
func _on_mouse_field_mouse_entered() -> void:
	hovering = true
	pass # Replace with function body.


func _on_mouse_field_mouse_exited() -> void:
	hovering = false
	pass # Replace with function body.



func _on_mouse_field_body_entered(body: Node2D) -> void:
	if body is Player:
		interact(body)
	pass # Replace with function body.
