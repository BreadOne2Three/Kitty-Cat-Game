extends Node2D


@onready var table_sprites = $Tables
@onready var table_cover_sprites = $TableCovers
@onready var ghost_table_cover = $GHOST_TableCovers
@onready var ghost_tables = $GHOST_Tables
@export var seats : int = 2


var furniture_obs = {
	"horizontal_bench": {
		"atlas_pos": Vector2i(0,0), #atlas starting position
		"size": Vector2i(3,1), #(X, Y) size of object
		"variants": 3, #number of patterns total
		"moves_hor": false #are sprites listed horizxontal order T/F
	},
	"vertical_bench": {
		"atlas_pos": Vector2i(38,0), #atlas starting position
		"size": Vector2i(1,2), #(X, Y) size of object
		"variants": 3, #number of patterns total
		"moves_hor": true, #are sprites listed horizxontal order T/F
		"comfort": 1,
		"looks": 1
	},
	"custom_height_tab": {
		"atlas_pos": Vector2i(4,0), 
		"size": Vector2i(3,3), 
		"variants": 3,
		"moves_hor": true,
		"comfort": 1,
		"looks": 1
	},
	"custom_width_tab": {
		"atlas_pos": Vector2i(14,0), 
		"size": Vector2i(3,2), 
		"variants": 3,
		"moves_hor": true,
		"comfort": 1,
		"looks": 1
	},
	"two_seater": {
		"atlas_pos": Vector2i(24,0),
		"size": Vector2i(2,2),
		"variants": 6,
		"moves_hor": true,
		"comfort": 1,
		"looks": 1
	},
	"one_seater": {
		"atlas_pos": Vector2i(42,0),
		"size": Vector2i(1, 2),
		"variants": 3,
		"moves_hor": true,
		"comfort": 1,
		"looks": 1
	},
	"japanese_table": {
		"atlas_pos": Vector2i(54,0),
		"size": Vector2i(2,2),
		"variants": 8,
		"moves_hor": true,
		"comfort": 1,
		"looks": 1
	},
	"simple_desk":{
		"atlas_pos": Vector2i(72,0),
		"size": Vector2i(2,2),
		"variants":4,
		"moves_hor": true,
		"comfort": 1,
		"looks": 1
		}
	
}
const tile_source : int = 0


var world_pos = Vector2.ZERO
var atlas_pos = Vector2.ZERO


##JSON KEYS
var atlas_pos_key = "atlas_pos"
var atlas_size_key = "size"
var atlas_variants_key = "variants"
var moves_horizontal_key = "moves_hor"
var comfort_key = "comfort"
var looks_key = "looks"

var json_names = ["horizontal_bench", "vertical_bench", "custom_height_tab", "custom_width_tab", "two_seater", "one_seater", "japanese_table", "simple_desk"]

var table_mat_left_atlas = Vector2i(64,0)
var table_mat_left_size = Vector2i(1,2) 
var table_mat_right_atlas = Vector2i(66,0)
var table_mat_right_size = Vector2i(1,2)

##if the width of the sprite is odd, offset its world position by `offset`
var offset = Vector2(16,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	table_sprites
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
