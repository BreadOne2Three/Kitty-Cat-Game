extends Node2D
class_name GenericSpawnableObject

#External Variables for Customization
##Icon to represent the spawned object
@export var image_texture : CompressedTexture2D
##reference to the object to be spawned
@export var associated_object : PackedScene
##If the object comes with multiple textures, specify which to show, this is for themes, not objects (so seats 2 and seats 4 would be object_version not texture_version)
@export var texture_version : int = 0
##if an object comes in multiple forms (e.g. the table object), have it spawn with the appropriate form
@export var object_version : int = 0
##for displaying a tooltip on what the item is
@export var tooltip_text : String = ""
## Where spawned objects should be placed (set this reference)
@export var spawn_parent : Node2D

#nodes for reference
@onready var sprite_dis = $StaticBody2D/Sprite2D
@onready var body = $StaticBody2D
@onready var tooltip = $Tooltip
@onready var tooltip_textbox = $Tooltip/RichTextLabel

var spawn_ref : Node2D

var is_dragging : bool = false
var is_hovering : bool = false
var offset : Vector2 = Vector2.ZERO 
var drag_instance : Node2D = null
var original_position : Vector2

signal object_spawned_and_placed(instance:Node2D)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if image_texture && associated_object:
		sprite_dis.texture = image_texture
	tooltip_textbox.text = "[center]" + tooltip_text
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		followMouse()
	elif is_hovering:
		displayTooltip()
	else:
		tooltip.visible = false
		sprite_dis.visible = false
		return

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		onClick(event)

func followMouse():
	#change self to the instanced object
	#self.global_position = get_global_mouse_position() - offset
	
	pass

func displayTooltip():
	var visual_offset = Vector2(5,5)
	$Control.global_position = get_global_mouse_position() + visual_offset
	$Control.visible=true

func onClick(event: InputEvent):
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_hovering and not is_dragging:
			is_dragging = true
			spawnObject()
			is_hovering = false
	#elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#if is_dragging:
			#endDragging()
	elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if is_dragging:
			endDragging()
	#if is_hovering:
		#is_dragging = true
		#spawnObject()
		#is_hovering = false
	#else:
		#return

func despawnObject():
	pass

func endDragging():
	despawnObject()


func spawnObject():
	pass


func is_placeable(placeable:RectangleShape2D, placeable_pos:Transform2D, boundary:RectangleShape2D, boundary_pos:Transform2D) -> bool:
	var placeable_rect = get_global_rect_from_shape(placeable, placeable_pos)
	var boundary_rect = get_global_rect_from_shape(boundary, boundary_pos)
	
	return boundary_rect.encloses(placeable_rect)
	pass
	
func get_global_rect_from_shape(shape: RectangleShape2D, transform: Transform2D) -> Rect2:
	var size = shape.size
	var theposition = transform.origin - size / 2  # center to top-left
	return Rect2(theposition, size)

func _on_static_body_2d_mouse_entered() -> void:
	is_hovering = true
	tooltip.visible = true
	offset = get_global_mouse_position() - global_position
func _on_static_body_2d_mouse_exited() -> void:
	is_hovering = false
	tooltip.visible = false
