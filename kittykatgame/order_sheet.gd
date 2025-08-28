extends Interactable
class_name OrderSheet

var order_data: OrderData
var customer_table_id: int

func _init():
	interaction_type = InteractionType.PICKUP
	interaction_time = 0.5

func _custom_interaction_check(player: Player) -> bool:
	return player.inventory.can_add_item()

func _execute_interaction(player: Player):
	player.inventory.add_item(self)
	queue_free()
	super._execute_interaction(player)
