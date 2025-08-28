extends Node2D
class_name Dish

@export var customer_order : int = 1
@export var dish_number : int = 1
@export var button_visibility : bool = false

@onready var button = $Button

var action_type : FranchiseGlobal.HIGHLIGHT = FranchiseGlobal.HIGHLIGHT.PICKUP_ORDER
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setDishNum(customer_order)

func getActionType()-> FranchiseGlobal.HIGHLIGHT:
	return action_type
func displayDish(table_num: int):
	setDishNum(table_num)
	customer_order = table_num
	button.disabled = false
	self.visible = true
	print("ready to go for ", table_num)
func hideDish():
	setDishNum(1)
	button.disabled = false
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setDishNum(num: int ):
	$number.frame = num-1 #frame 0 is 1, 1 is 2, etc
	dish_number = num

func getDishNum() -> int:
	return dish_number
	
func getInteractPos()->Vector2:
	return $InteractPos.global_position

signal button_pressed(object:Node2D)
func _on_button_pressed() -> void:
	button_pressed.emit(self)
	waiting_for_player = true
	button.disabled = true	

func getServePos():
	return $InteractPos/Area2D/CollisionShape2D

var waiting_for_player : bool = false
signal deleteDish(num:int)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and waiting_for_player:
		print("deleting dish: ", dish_number)
		deleteDish.emit(dish_number)
		
		waiting_for_player = false
	pass # Replace with function body.

func getTableNum() -> int:
	return dish_number
