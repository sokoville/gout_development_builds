extends Node3D

const PlayerFile = preload("res://scenes/player.tscn")
const RainFile = preload("res://scenes/prefabs/particles/rain.tscn")

var bullet_holes : Array = []

func despawn_player():
	if self.has_node("Player"):
		self.get_node("Player").queue_free()
		self.set_meta("player_spawned", false)

func clear_map():
	if self.get_child(0) != null:
		self.set_meta("map", "")
		self.get_child(0).queue_free()

func spawn_player(map):
	var player_instance = PlayerFile.instantiate()
	self.add_child(player_instance)
	player_instance.global_translate(map.get_meta("player_spawn"))
	self.set_meta("player_spawned", true)

func load_map(map_name):
	var newMap = load("res://scenes/maps/" + map_name)
	
	if newMap != null:
		clear_map()
		
		var new_map = newMap.instantiate()
		self.add_child(new_map)
		self.move_child(new_map, 0)
		self.set_meta("map", new_map.get_path())
		
		if self.get_meta("player_spawned") == true:
			self.get_node("Player").global_position = new_map.get_meta("player_spawn")
		else:
			spawn_player(new_map)

#func add_rain()

func _ready():
	load_map("test_map2.tscn")
	#add_rain()
