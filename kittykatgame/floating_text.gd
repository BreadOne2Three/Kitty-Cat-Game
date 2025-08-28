extends Control
class_name FloatingText

@onready var rich_text_label: RichTextLabel = $RichTextLabel
var original_text: String #text being "waved" around
var wave_amplitude: float = 1.5 #how high it waves, how "violent" it waves in conjunction with speed
var wave_frequency: float = 2.0 #how frequent it waves in a period
var wave_speed: float = 3.0  #how fast it moves
var float_speed: float = 50.0 #the speed in which it floats north
var drift_speed: float = 20.0 #the speed in which it drifts west
var animation_time: float = 0.0 #keep track of curr animation time
var total_duration: float = 5.0 #max animation time

# different animation phases time
var scale_up_duration: float = 3.5 #at 3.5 seconds, stop scaling size
var fade_start_time: float = 4.0 #at 4.0 seconds, start fading away, finish by 5.0

func _ready():
	#initialize
	modulate.a = 1.0
	scale = Vector2(1.0, 1.0)
	
func setup_floating_text(text: String, start_position: Vector2):
	#original_text = text
	var dec_pos = text.length() - 2
	text = text.insert(dec_pos, ".")
	original_text = text
	rich_text_label.text = "[center]" + text + "[/center]"
	global_position = start_position
	
	# start the animation
	animation_time = 0.0
	
func _process(delta):
	if animation_time >= total_duration:
		queue_free()
		return
		
	animation_time += delta
	
	# phase 1: scale up size
	if animation_time <= scale_up_duration:
		var scale_progress = animation_time / scale_up_duration
		var ease_scale = ease_out_back(scale_progress)
		scale = Vector2.ONE * (0.5 + 0.5 * ease_scale)
	
	# phase 2: float upward and drift
	var float_offset = Vector2(
		-drift_speed * animation_time,  # drift westward
		-float_speed * animation_time   # float upward
	)
	
	# sin wave effect
	apply_wave_effect(delta)
	
	# fade out
	if animation_time >= fade_start_time:
		var fade_progress = (animation_time - fade_start_time) / (total_duration - fade_start_time)
		modulate.a = 1.0 - ease_in_quad(fade_progress)
	
	# apply position offset
	position += Vector2(0, -float_speed * delta) + Vector2(-drift_speed * delta, 0)

func apply_wave_effect(delta):
	# create wave effect by modifying individual character positions
	var wave_text = ""
	var base_time = animation_time * wave_speed
	
	for i in range(original_text.length()):
		var char = original_text[i]
		if char == " ":
			wave_text += " "
			continue
			
		# roughly measure the gap between each number
		var char_wave_time = base_time + (i * 0.2)  # offset characters
		var wave_y_offset = sin(char_wave_time * wave_frequency) * wave_amplitude
		
		# apply vertical
		var offset_pixels = int(wave_y_offset)
		if offset_pixels > 0:
			wave_text += "[font_size=12][color=transparent]" + "i".repeat(abs(offset_pixels)) + "[/color][/font_size]"
		
		wave_text += char
		
		if offset_pixels < 0:
			wave_text += "[font_size=12][color=transparent]" + "i".repeat(abs(offset_pixels)) + "[/color][/font_size]"
	
	rich_text_label.text = "[center]" + wave_text + "[/center]"

# easing functions
func ease_out_back(t: float) -> float:
	var c1 = 1.70158
	var c3 = c1 + 1.0
	return 1.0 + c3 * pow(t - 1.0, 3.0) + c1 * pow(t - 1.0, 2.0)

func ease_in_quad(t: float) -> float:
	return t * t


static func create_floating_text(text: String, start_pos: Vector2, parent_node: Node) -> FloatingText:
	var floating_text_scene = preload("res://scenes/franchise_mode/floating_text.tscn")  
	var floating_text = floating_text_scene.instantiate()
	parent_node.add_child(floating_text)
	floating_text.setup_floating_text(text, start_pos)
	return floating_text
