extends Node2D
class_name PartySpawner

#party object and node references
var party = preload("res://scenes/franchise_mode/party.tscn")
@onready var front_of_queue = $SpawnNode
@onready var timer = $customer_spawn_timer
@onready var SFX = $SFX
var customer_enter_audio = preload("res://assets/audio/shop_door_bell.wav")


#queued parties
#how many parties are in line
var parties_in_queue : int = 0
var queue = []
var max_queue : int

#seated Parties
#how many parties are seated, subtracts from queue
var seated_parties : int = 0
var seated_array = [] #reference to all seated customers


#all customers
var all_customers = [] # refernce to customers in queue and seated_array but not `ticketed` customers
#indices and counters
var total_customers : int = 0 #number of customers encountered total -- used for incrementing level script


#time variables
var time_surpassed : float = 0.0
var time_to_next_customer : float = 2.0


func _ready():
	spawn_party(true, FranchiseGlobal.PARTY_TYPE.PATIENT, 4)	
	spawn_party(true, FranchiseGlobal.PARTY_TYPE.PATIENT, 4)
	pass
	
	
func _process(delta: float) -> void:	
	pass
	
	
#TODO: implement script ability with variability
#potentially using function parameters?
func spawn_party(custom_spawn:bool = false, customer_type:FranchiseGlobal.PARTY_TYPE = FranchiseGlobal.PARTY_TYPE.NORMAL, party_size : int = 1, party_color_org:FranchiseGlobal.PARTY_COLOR_ORG = FranchiseGlobal.PARTY_COLOR_ORG.RANDOM):
	var temp = party.instantiate()
	
	var spawn_pos = front_of_queue.global_position
	spawn_pos.y += parties_in_queue * -60

	#✅TODO: Calculate global position 
	add_child(temp)
	temp.init(party_size, customer_type, GameConfig.getDispositionTimers(customer_type))
	temp.global_position = spawn_pos
	temp.z_index = 2
	
	#TODO: Implement party spawn customization here
	if (custom_spawn):
		
		pass
	
	
	
	
	
	#✅TODO: Implement Sound Effect of Entrance
	SFX.stream = customer_enter_audio
	SFX.play()
	
	
	all_customers.append(temp)
	queue.append(temp)
	temp.party_seated.connect(_on_party_seated.bind(temp)) #when party is seated, handle the arrays they are in
	
	total_customers += 1 #increment total_customers for proper indices access
	parties_in_queue += 1






func getSpawnNodesPosition() -> Vector2:
	return front_of_queue.global_position




func _on_party_seated(party):
	print('hello')
	queue.erase(party)
	parties_in_queue -= 1
	seated_parties += 1
	seated_array.append(party)
	pass
