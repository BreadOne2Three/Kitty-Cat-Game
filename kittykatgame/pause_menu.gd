extends Control

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("RESET")
	self.visible = false

	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused != false:
		resume()

func resume():
	get_tree().paused = false
	self.visible = false
	anim.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	self.visible = true
	anim.play("blur")
	
func quit():
	get_tree().quit()



func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	print("options")

func _on_quit_pressed() -> void:
	quit()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
