# LevelEnemyPartyDesigner.gd - Multi-party level editor with popup customizer
extends Control
class_name LevelEnemyPartyDesigner

# Constants
const MIN_PARTY_SIZE = 1
const MAX_PARTY_SIZE = 6
const COORDINATE_GRID_SIZE = 500

const COORDINATE_GRID_SIZE_X = 640
const COORDINATE_GRID_SIZE_Y = 360

const GRID_CELL_SIZE = 40

# UI References - Current Party Editor
@onready var party_size_label = $HBoxContainer/VBoxContainer/CurrentParty/SizeControls/PartySizeLabel
@onready var size_down_btn = $HBoxContainer/VBoxContainer/CurrentParty/SizeControls/SizeDownBtn
@onready var size_up_btn = $HBoxContainer/VBoxContainer/CurrentParty/SizeControls/SizeUpBtn
@onready var enemy_container = $HBoxContainer/VBoxContainer/CurrentParty/EnemyContainer
@onready var party_type_btn = $HBoxContainer/VBoxContainer/CurrentParty/PartyTypeBtn
@onready var spawn_percentage_input = $HBoxContainer/VBoxContainer/CurrentParty/SpawnControls/SpawnPercentageInput

# UI References - Party Management
@onready var party_list = $HBoxContainer/VBoxContainer/PartyManagement/PartyList
@onready var add_party_btn = $HBoxContainer/VBoxContainer/PartyManagement/Controls/AddPartyBtn
@onready var remove_party_btn = $HBoxContainer/VBoxContainer/PartyManagement/Controls/RemovePartyBtn
@onready var party_select = $HBoxContainer/VBoxContainer/PartyManagement/PartySelect

# UI References - Level Start Prompt Editor
@onready var level_number_input = $HBoxContainer/VBoxContainer/LevelStartPrompt/LevelNumberInput
@onready var level_title_input = $HBoxContainer/VBoxContainer/LevelStartPrompt/LevelTitleInput
@onready var level_description_input = $HBoxContainer/VBoxContainer/LevelStartPrompt/LevelDescriptionInput
@onready var preview_start_prompt_btn = $HBoxContainer/VBoxContainer/LevelStartPrompt/PreviewBtn

# UI References - Tutorial System
@onready var tutorial_list = $HBoxContainer/VBoxContainer/TutorialSystem/TutorialList
@onready var tutorial_text_input = $HBoxContainer/VBoxContainer/TutorialSystem/TutorialTextInput
@onready var tutorial_target_select = $HBoxContainer/VBoxContainer/TutorialSystem/TargetSelect
@onready var tutorial_x_input = $HBoxContainer/VBoxContainer/TutorialSystem/CoordinateControls/XInput
@onready var tutorial_y_input = $HBoxContainer/VBoxContainer/TutorialSystem/CoordinateControls/YInput
@onready var add_tutorial_btn = $HBoxContainer/VBoxContainer/TutorialSystem/Controls/AddTutorialBtn
@onready var remove_tutorial_btn = $HBoxContainer/VBoxContainer/TutorialSystem/Controls/RemoveTutorialBtn
@onready var table_size_field = $HBoxContainer/VBoxContainer/TutorialSystem/TableControls/TableSizeField
@onready var add_table_btn = $HBoxContainer/VBoxContainer/TutorialSystem/TableControls/AddTableBtn
@onready var remove_table_btn = $HBoxContainer/VBoxContainer/TutorialSystem/TableControls/RemoveTableBtn
@onready var coordinate_plotter = $HBoxContainer/CoordinatePlotter
@onready var plot_canvas = $HBoxContainer/CoordinatePlotter/PlotCanvas
@onready var coordinate_label = $HBoxContainer/CoordinatePlotter/CoordinateLabel

# UI References - Level Data & Export
@onready var day_time_input = $HBoxContainer/VBoxContainer/LevelData/DayTimeInput
@onready var export_btn = $HBoxContainer/VBoxContainer/ExportBtn

# UI References - Popup System
@onready var popup_container = $PopupContainer
@onready var level_intro_popup = $PopupContainer/AcceptDialog
@onready var level_intro_label = $PopupContainer/AcceptDialog/VBoxContainer/IntroLabel
@onready var level_intro_close = $PopupContainer/AcceptDialog/VBoxContainer/CloseBtn
@onready var tooltip_popup = $PopupContainer/TooltipPopup
@onready var tooltip_label = $PopupContainer/TooltipPopup/TooltipLabel

# Current party being edited
var current_party_size = 1
var enemy_sprites = []
var enemy_colors = []
var current_party_type_index = 0
var spawn_percentage = 0.0

# All parties for this level
var level_parties = []
var current_party_index = 0

# Level start prompt data
var level_start_prompt = {
	"world_level": "1-1",
	"title": "",
	"description": ""
}

# Tutorial system data
var tutorial_tooltips = []
var current_tutorial_index = -1
var selected_coordinate = Vector2(-1, -1)

# Target objects enum (you can customize this based on your game)


var tutorial_target_names = FranchiseGlobal.HIGHLIGHT.keys()

# Level data
var day_time = 24.0
var obs_spawn = []

# Color mapping
var color_map = {
	FranchiseGlobal.PARTY_COLOR.RED: Color.RED,
	FranchiseGlobal.PARTY_COLOR.YELLOW: Color.YELLOW,
	FranchiseGlobal.PARTY_COLOR.BLUE: Color.BLUE,
	FranchiseGlobal.PARTY_COLOR.GREEN: Color.GREEN
}

var color_names = ["red", "yellow", "blue", "green"]
var party_type_names = []

# Popup system
var active_tooltips = []

func _ready():
	setup_party_type_names()
	setup_tutorial_targets()
	setup_initial_level()
	setup_popup_system()
	setup_coordinate_plotter()
	connect_signals()
	update_display()

func setup_party_type_names():
	for key in FranchiseGlobal.PARTY_TYPE:
		party_type_names.append(key.to_lower())

func setup_tutorial_targets():
	tutorial_target_select.clear()
	for target_name in tutorial_target_names:
		tutorial_target_select.add_item(target_name)

func setup_initial_level():
	# Start with one party
	level_parties = [create_default_party()]
	current_party_index = 0
	load_current_party()
	day_time = 24.0
	
	# Initialize level start prompt
	level_number_input.text = level_start_prompt.world_level
	level_title_input.text = level_start_prompt.title
	level_description_input.text = level_start_prompt.description

func create_default_party() -> Dictionary:
	return {
		"party_type": party_type_names[0] if party_type_names.size() > 0 else "default",
		"party_size": 1,
		"party_colors": ["red"],
		"percentage_spawn": 0.0
	}

func setup_popup_system():
	# Make sure popup container exists
	if not popup_container:
		popup_container = Control.new()
		popup_container.name = "PopupContainer"
		popup_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(popup_container)
	
	# Create level intro popup if it doesn't exist
	if not level_intro_popup:
		create_level_intro_popup()
	
	# Create tooltip popup if it doesn't exist
	if not tooltip_popup:
		create_tooltip_popup()

func setup_coordinate_plotter():
	if not plot_canvas:
		return
		
	plot_canvas.custom_minimum_size = Vector2(COORDINATE_GRID_SIZE_X, COORDINATE_GRID_SIZE_Y)
	plot_canvas.gui_input.connect(_on_plot_canvas_input)
	plot_canvas.draw.connect(_on_plot_canvas_draw)
	
	coordinate_label.text = "Click on the grid to set coordinates"

func create_level_intro_popup():
	level_intro_popup = AcceptDialog.new()
	level_intro_popup.name = "LevelIntroPopup"
	level_intro_popup.title = "Level Introduction"
	level_intro_popup.size = Vector2(400, 300)
	level_intro_popup.popup_window = false
	
	var vbox = VBoxContainer.new()
	level_intro_label = RichTextLabel.new()
	level_intro_label.name = "IntroLabel"
	level_intro_label.custom_minimum_size = Vector2(350, 200)
	level_intro_label.fit_content = true
	level_intro_label.bbcode_enabled = true
	
	level_intro_close = Button.new()
	level_intro_close.name = "CloseBtn"
	level_intro_close.text = "Start Level"
	level_intro_close.pressed.connect(_on_intro_close_pressed)
	
	vbox.add_child(level_intro_label)
	vbox.add_child(level_intro_close)
	level_intro_popup.add_child(vbox)
	popup_container.add_child(level_intro_popup)

func create_tooltip_popup():
	tooltip_popup = PanelContainer.new()
	tooltip_popup.name = "TooltipPopup"
	tooltip_popup.visible = false
	tooltip_popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	tooltip_label = RichTextLabel.new()
	tooltip_label.name = "TooltipLabel"
	tooltip_label.custom_minimum_size = Vector2(200, 50)
	tooltip_label.fit_content = true
	tooltip_label.bbcode_enabled = true
	tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	tooltip_popup.add_child(tooltip_label)
	popup_container.add_child(tooltip_popup)

func connect_signals():
	# Current party editor signals
	size_down_btn.pressed.connect(_on_size_down_pressed)
	size_up_btn.pressed.connect(_on_size_up_pressed)
	party_type_btn.pressed.connect(_on_party_type_pressed)
	spawn_percentage_input.value_changed.connect(_on_spawn_percentage_changed)
	
	# Party management signals
	add_party_btn.pressed.connect(_on_add_party_pressed)
	remove_party_btn.pressed.connect(_on_remove_party_pressed)
	party_select.item_selected.connect(_on_party_selected)
	
	# Level start prompt signals
	level_number_input.text_changed.connect(_on_level_number_changed)
	level_title_input.text_changed.connect(_on_level_title_changed)
	level_description_input.text_changed.connect(_on_level_description_changed)
	preview_start_prompt_btn.pressed.connect(_on_preview_start_prompt_pressed)
	
	# Tutorial system signals
	add_tutorial_btn.pressed.connect(_on_add_tutorial_pressed)
	remove_tutorial_btn.pressed.connect(_on_remove_tutorial_pressed)
	add_table_btn.pressed.connect(_on_add_table_pressed)
	remove_table_btn.pressed.connect(_on_remove_table_pressed)
	
	tutorial_list.item_selected.connect(_on_tutorial_selected)
	tutorial_x_input.value_changed.connect(_on_tutorial_coordinates_changed)
	tutorial_y_input.value_changed.connect(_on_tutorial_coordinates_changed)
	
	# Level data signals
	day_time_input.value_changed.connect(_on_day_time_changed)
	
	# Export signal
	export_btn.pressed.connect(_on_export_pressed)

# === CURRENT PARTY EDITING ===
func _on_size_down_pressed():
	if current_party_size > MIN_PARTY_SIZE:
		current_party_size -= 1
		enemy_colors.pop_back()
		remove_last_enemy_sprite()
		update_display()
		save_current_party()

func _on_size_up_pressed():
	if current_party_size < MAX_PARTY_SIZE:
		current_party_size += 1
		enemy_colors.append(FranchiseGlobal.PARTY_COLOR.RED)
		add_enemy_sprite()
		update_display()
		save_current_party()

func _on_party_type_pressed():
	current_party_type_index = (current_party_type_index + 1) % party_type_names.size()
	update_party_type_display()
	save_current_party()

func _on_spawn_percentage_changed(value: float):
	spawn_percentage = clamp(value, 0.0, 1.0)
	save_current_party()

# === PARTY MANAGEMENT ===
func _on_add_party_pressed():
	save_current_party()
	level_parties.append(create_default_party())
	current_party_index = level_parties.size() - 1
	update_party_list()
	party_select.select(current_party_index)
	load_current_party()

func _on_remove_party_pressed():
	if level_parties.size() > 1:
		level_parties.remove_at(current_party_index)
		if current_party_index >= level_parties.size():
			current_party_index = level_parties.size() - 1
		update_party_list()
		party_select.select(current_party_index)
		load_current_party()

func _on_party_selected(index: int):
	if index != current_party_index:
		save_current_party()
		current_party_index = index
		load_current_party()

# === LEVEL START PROMPT EDITOR ===
func _on_level_number_changed(new_text: String):
	level_start_prompt.world_level = new_text

func _on_level_title_changed(new_text: String):
	level_start_prompt.title = new_text

func _on_level_description_changed(new_text: String):
	level_start_prompt.description = new_text

func _on_preview_start_prompt_pressed():
	var id = ("Level " + level_start_prompt.world_level)
	var title = level_start_prompt.title
	var description = level_start_prompt.description if level_start_prompt.description != "" else "No description available."
	show_level_intro(id, title, description)

func _on_add_table_pressed():
	if tutorial_x_input.value == 0 or tutorial_y_input.value == 0: return
	else:
		var table_loc = Vector2(tutorial_x_input.value, tutorial_y_input.value)
		var table_size = table_size_field.value
		var table_json = {"table_pos": table_loc, "seats": table_size}
		obs_spawn.append(table_json)

func _on_remove_table_pressed():
	if len(obs_spawn) == 0:
		return
	else:
		obs_spawn.pop_back()
		plot_canvas.queue_redraw()


# === TUTORIAL SYSTEM ===
func _on_add_tutorial_pressed():
	if tutorial_text_input.text.strip_edges() == "":
		show_tooltip("Please enter tutorial text first!", tutorial_text_input.global_position, 2.0)
		return
	
	var new_tutorial = {
		"text": tutorial_text_input.text,
		"target": tutorial_target_select.get_item_text(tutorial_target_select.selected),
		"x": tutorial_x_input.value,
		"y": tutorial_y_input.value
	}
	
	tutorial_tooltips.append(new_tutorial)
	update_tutorial_list()
	tutorial_text_input.clear()

func _on_remove_tutorial_pressed():
	if current_tutorial_index >= 0 and current_tutorial_index < tutorial_tooltips.size():
		tutorial_tooltips.remove_at(current_tutorial_index)
		current_tutorial_index = -1
		update_tutorial_list()
		plot_canvas.queue_redraw()

func _on_tutorial_selected(index: int):
	if index >= 0 and index < tutorial_tooltips.size():
		current_tutorial_index = index
		var tutorial = tutorial_tooltips[index]
		
		# Load tutorial data into inputs
		tutorial_text_input.text = tutorial.text
		tutorial_target_select.select(tutorial_target_names.find(tutorial.target))
		tutorial_x_input.value = tutorial.x
		tutorial_y_input.value = tutorial.y
		
		# Update selected coordinate
		selected_coordinate = Vector2(tutorial.x, tutorial.y)
		plot_canvas.queue_redraw()

func _on_tutorial_coordinates_changed(_value):
	selected_coordinate = Vector2(tutorial_x_input.value, tutorial_y_input.value)
	plot_canvas.queue_redraw()
	
	# Update current tutorial if one is selected
	if current_tutorial_index >= 0 and current_tutorial_index < tutorial_tooltips.size():
		tutorial_tooltips[current_tutorial_index].x = tutorial_x_input.value
		tutorial_tooltips[current_tutorial_index].y = tutorial_y_input.value
		update_tutorial_list()

func _on_plot_canvas_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = event.position
		var grid_x = int(local_pos.x / GRID_CELL_SIZE)
		var grid_y = int(local_pos.y / GRID_CELL_SIZE)
		
		# Update coordinate inputs
		tutorial_x_input.value = grid_x
		tutorial_y_input.value = grid_y
		selected_coordinate = Vector2(grid_x, grid_y)
		
		# Update coordinate label
		coordinate_label.text = "Coordinates: (%d, %d)" % [grid_x, grid_y]
		
		# Update current tutorial if one is selected
		if current_tutorial_index >= 0 and current_tutorial_index < tutorial_tooltips.size():
			tutorial_tooltips[current_tutorial_index].x = grid_x
			tutorial_tooltips[current_tutorial_index].y = grid_y
			update_tutorial_list()
		
		plot_canvas.queue_redraw()

func _on_plot_canvas_draw():
	if not plot_canvas:
		return
		
	# Draw grid
	for x in range(0, COORDINATE_GRID_SIZE_X + (GRID_CELL_SIZE), GRID_CELL_SIZE):
		plot_canvas.draw_line(Vector2(x, 0), Vector2(x, COORDINATE_GRID_SIZE_Y), Color.GRAY, 1)
	for y in range(0, COORDINATE_GRID_SIZE_Y + (GRID_CELL_SIZE), GRID_CELL_SIZE):
		plot_canvas.draw_line(Vector2(0, y), Vector2(COORDINATE_GRID_SIZE_X, y), Color.GRAY, 1)
	
	# Darken first row and first column
	for x in range(0, COORDINATE_GRID_SIZE_X, GRID_CELL_SIZE):
		for y in range(0, COORDINATE_GRID_SIZE_Y, GRID_CELL_SIZE):
			if y == 0:  # First row
				plot_canvas.draw_rect(Rect2(x, y, GRID_CELL_SIZE, GRID_CELL_SIZE), Color(0, 0, 0, 0.3))
			elif x == 0:  # First column
				plot_canvas.draw_rect(Rect2(x, y, GRID_CELL_SIZE, GRID_CELL_SIZE), Color(0, 0, 0, 0.3))
	
	# Draw tutorial positions
	for i in range(tutorial_tooltips.size()):
		var tutorial = tutorial_tooltips[i]
		var pos = Vector2(tutorial.x * GRID_CELL_SIZE + GRID_CELL_SIZE/2, tutorial.y * GRID_CELL_SIZE + GRID_CELL_SIZE/2)
		var color = Color.YELLOW if i == current_tutorial_index else Color.ORANGE
		plot_canvas.draw_circle(pos, 8, color)
		plot_canvas.draw_string(get_theme_default_font(), pos + Vector2(10, 0), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	for i in range(obs_spawn.size()):
		var table = obs_spawn[i]
		print(table["table_pos"])
		var pos = Vector2(table["table_pos"])
		pos = Vector2(pos.x * GRID_CELL_SIZE + GRID_CELL_SIZE/2, pos.y * GRID_CELL_SIZE + GRID_CELL_SIZE/2)
		var color = Color.YELLOW if i == current_tutorial_index else Color.BLUE
		plot_canvas.draw_circle(pos, 8, color)
		plot_canvas.draw_string(get_theme_default_font(), pos + Vector2(10, 0), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		plot_canvas.draw_string(get_theme_default_font(), pos + Vector2(-10, 0), str(int(table["seats"])), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	# Draw selected coordinate
	if selected_coordinate.x >= 0 and selected_coordinate.y >= 0:
		var pos = Vector2(selected_coordinate.x * GRID_CELL_SIZE + GRID_CELL_SIZE/2, selected_coordinate.y * GRID_CELL_SIZE + GRID_CELL_SIZE/2)
		plot_canvas.draw_circle(pos, 10, Color.RED)
		plot_canvas.draw_circle(pos, 8, Color.WHITE)
		
func update_tutorial_list():
	tutorial_list.clear()
	for i in range(tutorial_tooltips.size()):
		var tutorial = tutorial_tooltips[i]
		var display_text = "%d: %s at (%d,%d) [%s]" % [
			i + 1,
			tutorial.text.substr(0, 30) + ("..." if tutorial.text.length() > 30 else ""),
			tutorial.x,
			tutorial.y,
			tutorial.target
		]
		tutorial_list.add_item(display_text)

func _on_day_time_changed(value: float):
	day_time = value

func _on_intro_close_pressed():
	level_intro_popup.hide()

# === PARTY DATA MANAGEMENT ===
func save_current_party():
	if current_party_index >= 0 and current_party_index < level_parties.size():
		var color_strings = []
		for color_enum in enemy_colors:
			var color_keys = FranchiseGlobal.PARTY_COLOR.keys()
			var color_values = FranchiseGlobal.PARTY_COLOR.values()
			var color_index = color_values.find(color_enum)
			if color_index >= 0:
				color_strings.append(color_keys[color_index].to_lower())
			else:
				color_strings.append("red")
		
		level_parties[current_party_index] = {
			"party_type": party_type_names[current_party_type_index] if current_party_type_index < party_type_names.size() else "default",
			"party_size": current_party_size,
			"party_colors": color_strings,
			"percentage_spawn": spawn_percentage
		}

func load_current_party():
	if current_party_index >= 0 and current_party_index < level_parties.size():
		var party = level_parties[current_party_index]
		
		current_party_type_index = party_type_names.find(party.party_type)
		if current_party_type_index == -1:
			current_party_type_index = 0
		
		current_party_size = party.party_size
		enemy_colors.clear()
		
		for color_name in party.party_colors:
			var color_key = color_name.to_upper()
			if FranchiseGlobal.PARTY_COLOR.has(color_key):
				enemy_colors.append(FranchiseGlobal.PARTY_COLOR[color_key])
			else:
				enemy_colors.append(FranchiseGlobal.PARTY_COLOR.RED)
		
		spawn_percentage = party.percentage_spawn
		spawn_percentage_input.value = spawn_percentage
		
		rebuild_enemy_sprites()
		update_display()

func rebuild_enemy_sprites():
	for sprite in enemy_sprites:
		sprite.queue_free()
	enemy_sprites.clear()
	
	for i in range(current_party_size):
		add_enemy_sprite()

# === UI MANAGEMENT ===
func add_enemy_sprite():
	var enemy_sprite = create_enemy_sprite(enemy_sprites.size())
	enemy_container.add_child(enemy_sprite)
	enemy_sprites.append(enemy_sprite)

func remove_last_enemy_sprite():
	if enemy_sprites.size() > 0:
		var last_sprite = enemy_sprites.pop_back()
		last_sprite.queue_free()

func create_enemy_sprite(index: int) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(64, 64)
	
	var sprite = ColorRect.new()
	if index < enemy_colors.size():
		sprite.color = color_map[enemy_colors[index]]
	else:
		sprite.color = Color.RED
	sprite.custom_minimum_size = Vector2(48, 48)
	sprite.size = Vector2(48, 48)
	sprite.position = Vector2(8, 8)
	
	var hitbox = Button.new()
	hitbox.flat = true
	hitbox.custom_minimum_size = Vector2(64, 64)
	hitbox.size = Vector2(64, 64)
	hitbox.modulate.a = 0.0
	hitbox.pressed.connect(func(): cycle_enemy_color(index))
	
	container.add_child(sprite)
	container.add_child(hitbox)
	container.name = "Enemy_%d" % index
	
	return container

func cycle_enemy_color(index: int):
	if index < enemy_colors.size():
		var current_color = enemy_colors[index]
		var color_values = FranchiseGlobal.PARTY_COLOR.values()
		var current_index = color_values.find(current_color)
		
		var next_index = (current_index + 1) % color_values.size()
		enemy_colors[index] = color_values[next_index]
		
		update_enemy_sprite_color(index)
		save_current_party()

func update_enemy_sprite_color(index: int):
	if index < enemy_sprites.size():
		var sprite = enemy_sprites[index].get_child(0)
		if index < enemy_colors.size():
			sprite.color = color_map[enemy_colors[index]]

func update_display():
	update_party_size_label()
	update_button_states()
	update_party_type_display()
	update_party_list()

func update_party_size_label():
	party_size_label.text = "Party Size: %d" % current_party_size

func update_button_states():
	size_down_btn.disabled = (current_party_size <= MIN_PARTY_SIZE)
	size_up_btn.disabled = (current_party_size >= MAX_PARTY_SIZE)
	remove_party_btn.disabled = (level_parties.size() <= 1)
	remove_tutorial_btn.disabled = (tutorial_tooltips.size() == 0)

func update_party_type_display():
	if current_party_type_index < party_type_names.size():
		party_type_btn.text = "Party Type: %s" % party_type_names[current_party_type_index].capitalize()
	else:
		party_type_btn.text = "Party Type: Default"

func update_party_list():
	party_select.clear()
	for i in range(level_parties.size()):
		var party = level_parties[i]
		var display_text = "Party %d: %s (%d enemies, %.0f%%)" % [
			i + 1, 
			party.party_type.capitalize(), 
			party.party_size, 
			party.percentage_spawn * 100
		]
		party_select.add_item(display_text)
	
	if current_party_index >= 0 and current_party_index < party_select.get_item_count():
		party_select.select(current_party_index)

# === EXPORT FUNCTIONALITY ===
func _on_export_pressed():
	save_current_party()
	export_level_data()

func export_level_data():
	var level_data = {
		"enemy_parties": level_parties,
		"obs_spawn": obs_spawn,
		"day_time": day_time,
		"level_start_prompt": level_start_prompt,
		"tutorial_tooltips": tutorial_tooltips
	}
	
	var json_string = JSON.stringify(level_data, "\t")
	print("Exported Level Data:")
	print(json_string)
	
	DisplayServer.clipboard_set(json_string)
	save_level_to_file(json_string)

func save_level_to_file(json_string: String):
	var file = FileAccess.open("res://scenes/franchise_mode/levels/scripts/"+ level_start_prompt["world_level"] +".json", FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Level data saved to res://scenes/franchise_mode/levels/scripts/"+level_start_prompt["world_level"] +".json")

# === POPUP SYSTEM API ===
func show_level_intro(id: String, title: String, description: String):
	level_intro_popup.title = id
	level_intro_label.text = "[center][b]%s[/b][/center]\n\n%s" % [title, description]
	level_intro_popup.popup_centered()

func show_tooltip(text: String, position: Vector2, duration: float = 3.0):
	tooltip_label.text = text
	tooltip_popup.position = position
	tooltip_popup.visible = true
	
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_on_tooltip_timeout.bind(timer))
	add_child(timer)
	timer.start()
	
	active_tooltips.append(timer)

func show_tooltip_for_node(text: String, target_node: Control, duration: float = 3.0):
	var global_pos = target_node.global_position
	var offset = Vector2(target_node.size.x + 10, target_node.size.y / 2)
	show_tooltip(text, global_pos + offset, duration)

func _on_tooltip_timeout(timer: Timer):
	tooltip_popup.visible = false
	timer.queue_free()
	active_tooltips.erase(timer)

func hide_all_tooltips():
	tooltip_popup.visible = false
	for timer in active_tooltips:
		timer.queue_free()
	active_tooltips.clear()

# === PUBLIC API ===
func set_obs_spawn_data(obs_data: Array):
	obs_spawn = obs_data

func get_level_data() -> Dictionary:
	save_current_party()
	return {
		"enemy_parties": level_parties,
		"obs_spawn": obs_spawn,
		"day_time": day_time,
		"level_start_prompt": level_start_prompt,
		"tutorial_tooltips": tutorial_tooltips
	}

func load_level_data(data: Dictionary):
	if data.has("enemy_parties") and data.enemy_parties.size() > 0:
		level_parties = data.enemy_parties
	else:
		level_parties = [create_default_party()]
	
	if data.has("day_time"):
		day_time = data.day_time
		day_time_input.value = day_time
	if data.has("obs_spawn"):
		obs_spawn = data.obs_spawn
	if data.has("level_start_prompt"):
		level_start_prompt = data.level_start_prompt
		level_number_input.text = level_start_prompt.world_level
		level_title_input.text = level_start_prompt.title
		level_description_input.text = level_start_prompt.description
	if data.has("tutorial_tooltips"):
		tutorial_tooltips = data.tutorial_tooltips
		update_tutorial_list()
	
	current_party_index = 0
	load_current_party()

func get_tutorial_data() -> Array:
	return tutorial_tooltips

func get_level_start_prompt() -> Dictionary:
	return level_start_prompt

# ===== SCENE STRUCTURE =====
# LevelEnemyPartyDesigner (Control)
# ├── VBoxContainer
# │   ├── CurrentParty (VBoxContainer) - "Current Party Editor"
# │   │   ├── SizeControls (HBoxContainer)
# │   │   │   ├── SizeDownBtn (Button) "◄"
# │   │   │   ├── PartySizeLabel (Label)
# │   │   │   └── SizeUpBtn (Button) "►"
# │   │   ├── EnemyContainer (HBoxContainer)
# │   │   ├── PartyTypeBtn (Button)
# │   │   └── SpawnControls (HBoxContainer)
# │   │       ├── SpawnLabel (Label) "Spawn %:"
# │   │       └── SpawnPercentageInput (SpinBox)
# │   ├── PartyManagement (VBoxContainer) - "Party Management"
# │   │   ├── PartyList (VBoxContainer) - Shows party summaries
# │   │   ├── Controls (HBoxContainer)
# │   │   │   ├── AddPartyBtn (Button) "Add Party"
# │   │   │   └── RemovePartyBtn (Button) "Remove Party"
# │   │   └── PartySelect (OptionButton)
# │   ├── LevelStartPrompt (VBoxContainer) - "Level Start Prompt Editor"
# │   │   ├── LevelNumberLabel (Label) "World-Level:"
# │   │   ├── LevelNumberInput (LineEdit) placeholder="1-1"
# │   │   ├── LevelTitleLabel (Label) "Level Title (optional):"
# │   │   ├── LevelTitleInput (LineEdit) placeholder="Enter level title..."
# │   │   ├── LevelDescriptionLabel (Label) "Level Description:"
# │   │   ├── LevelDescriptionInput (TextEdit) placeholder="Enter level description..."
# │   │   └── PreviewBtn (Button) "Preview Start Prompt"
# │   ├── TutorialSystem (VBoxContainer) - "Tutorial System"
# │   │   ├── TutorialList (ItemList) - Shows all tutorial tooltips
# │   │   ├── TutorialTextLabel (Label) "Tutorial Text:"
# │   │   ├── TutorialTextInput (TextEdit) placeholder="Enter tutorial text..."
# │   │   ├── TargetLabel (Label) "Target Object:"
# │   │   ├── TargetSelect (OptionButton) - Player, Enemy, Powerup, etc.
# │   │   ├── CoordinateControls (HBoxContainer)
# │   │   │   ├── XLabel (Label) "X:"
# │   │   │   ├── XInput (SpinBox) min=0, max=100, step=1
# │   │   │   ├── YLabel (Label) "Y:"
# │   │   │   └── YInput (SpinBox) min=0, max=100, step=1
# │   │   ├── Controls (HBoxContainer)
# │   │   │   ├── AddTutorialBtn (Button) "Add Tutorial"
# │   │   │   └── RemoveTutorialBtn (Button) "Remove Tutorial"
# │   │   └── CoordinatePlotter (VBoxContainer) - "Coordinate Plotter"
# │   │       ├── CoordinateLabel (Label) "Click on grid to set coordinates"
# │   │       └── PlotCanvas (Control) - Interactive grid for plotting
# │   ├── LevelData (VBoxContainer) - "Level Settings"
# │   │   ├── DayTimeLabel (Label) "Day Time:"
# │   │   └── DayTimeInput (SpinBox) min=0.1, max=48.0, step=0.1
# │   └── ExportBtn (Button) "Export Level JSON"
# └── PopupContainer (Control) - Full screen container for popups
#     ├── LevelIntroPopup (AcceptDialog)
#     │   └── VBoxContainer
#     │       ├── IntroLabel (RichTextLabel)
#     │       └── CloseBtn (Button)
#     └── TooltipPopup (PanelContainer)
#         └── TooltipLabel (RichTextLabel)

# ===== TUTORIAL SYSTEM FEATURES =====
# 1. Interactive coordinate plotter with visual grid
# 2. Click-to-place coordinate selection
# 3. Visual representation of all tutorial positions
# 4. Target object selection from predefined enum
# 5. Tutorial list with edit/remove functionality
# 6. Real-time coordinate updates when clicking grid
# 7. Export includes tutorial data in JSON format

# ===== LEVEL START PROMPT FEATURES =====
# 1. World-level number input (e.g., "1-1", "2-3")
# 2. Optional level title input
# 3. Level description text area
# 4. Preview button to test the start prompt
# 5. All data exported with level JSON

# ===== COORDINATE PLOTTER DETAILS =====
# - 500x500 pixel grid divided into 25x25 pixel cells (20x20 grid)
# - Left-click to select coordinates
# - Visual indicators for existing tutorials (orange circles)
# - Selected tutorial highlighted in yellow
# - Current coordinate selection shown in red
# - Grid coordinates displayed as "Coordinates: (x, y)"
# - Tutorial positions numbered for easy identification
