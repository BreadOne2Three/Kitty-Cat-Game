class_name Customer
extends Node2D

var my_color:FranchiseGlobal.PARTY_COLOR
signal draggingParty(me : Customer)
signal doneDraggingParty

func init(color:FranchiseGlobal.PARTY_COLOR):
	my_color = color
	changeToColor(color)

func getSprite():
	return $Sprite2D.texture
func getModulate() -> Color:
	return $Sprite2D.modulate
func getScale() -> Vector2:
	return $Sprite2D.scale
	
	
var tween_speed : float = .5
#minimum sqrt(x) distance it needs to be before it bothers with tweening
#var min_distance : float = 50.0
var target : Vector2
func moveToPos(pos : Vector2):
	target = pos
	var tween = create_tween()
	#ease in out
	tween.tween_property(self, "global_position", target, tween_speed).set_ease(Tween.EASE_IN_OUT)


#change the sprite to the appropriate color
func changeToColor(color:FranchiseGlobal.PARTY_COLOR):
	#enum PARTY_COLOR {YELLOW, RED, BLUE, GREEN}
	var sprite = $Sprite2D
	match(color):
		FranchiseGlobal.PARTY_COLOR.YELLOW:
			sprite.modulate = Color(1,1,0,1)
		FranchiseGlobal.PARTY_COLOR.RED:
			sprite.modulate = Color(1,0,0,1)
		FranchiseGlobal.PARTY_COLOR.BLUE:
			sprite.modulate = Color(0,0,1,1)
		FranchiseGlobal.PARTY_COLOR.GREEN:
			sprite.modulate = Color(0,1,0,1)




func _process(_delta: float) -> void:
	
	#$debug_textpopup.setText()
	if (draggable):
		if Input.is_action_just_pressed("click"):
			#keep moving party
			FranchiseGlobal.is_dragging = true
			draggingParty.emit(self)
			#initialPos = global_position



		
		#snap back to original position OR go to new one
		elif (Input.is_action_just_released("click")):
			FranchiseGlobal.is_dragging = false
			draggable = false
			doneDraggingParty.emit()
			var tween = get_parent().create_tween()



var draggable : bool = false


	
func _on_area_2d_mouse_entered() -> void:
	#user grabbed party
	if (not FranchiseGlobal.is_dragging) and (not get_parent().is_seated):
		highlight(true)
		draggable = true
		#scale = Vector2(1.05, 1.05)
	else:
		#design it so you can rotate customers around chairs
		pass

func _on_area_2d_mouse_exited() -> void:
	#user let go of mouse in range of seating
	if not FranchiseGlobal.is_dragging:
		highlight(false)
		draggable = false
		#scale = Vector2(1, 1)
	
func highlight(active: bool):
	scale = Vector2(1.05, 1.05) if active else Vector2(1, 1)
