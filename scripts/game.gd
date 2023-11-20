extends Node

@onready var WorldNode := get_node("3D/World")

@export var app_name : String = "Gout"
@export var version : String = "devtest1"
@export var engine_version : String = "ERR engine_version not loaded"
@export var renderer_version : String = "ERR renderer_version not loaded"

@export var global_settings = {
	"locale" : "en",
	"mouse_sensitivity" : 0.05,
	"controller_sensitivity" : 0.05,
	"window_mode" : DisplayServer.WINDOW_MODE_WINDOWED,
}

func set_locale(locale):
	global_settings.locale = locale
	TranslationServer.set_locale(locale)

func save_settings():
	var save_file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	
	for setting in global_settings:
		var setting_dict = {setting : global_settings[setting]}
		var json_string = JSON.stringify(setting_dict)
		save_file.store_line(json_string)
	
func load_saved_settings():
	if FileAccess.file_exists("user://settings.save"):
		
		var save_file = FileAccess.open("user://settings.save", FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json = JSON.new()
			var line = save_file.get_line()
			var parse_result = json.parse(line)
			var setting = json.get_data()
			global_settings.merge(setting, true)

func pause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	get_node("2D/UI/Control/PauseMenu").load_menu()
	if get_node("3D/World").has_node("Player"):
		get_node("3D/World").get_node("Player").get_node("UI").visible = false
	
func unpause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	get_node("2D/UI/Control/PauseMenu").visible = false
	if get_node("3D/World").has_node("Player"):
		get_node("3D/World").get_node("Player").get_node("UI").visible = true

func _init():
	engine_version = "Godot Engine " + Engine.get_version_info().string
	renderer_version = "Vulkan API " + RenderingServer.get_video_adapter_api_version()

func _ready():
	var debug = ""
	if OS.is_debug_build():
		debug = "DEBUG_BUILD"
		
	if OS.has_feature("editor"):
		var date = Time.get_date_dict_from_system()
		version = "devtest" + str(date.day) + str(date.month) + str(date.year - 2000) + " " + Time.get_time_string_from_system()
	else:
		load_saved_settings()
		
	var window_title = (app_name + " " + version + " " + debug + " / " + engine_version + " / " + renderer_version)
	
	DisplayServer.window_set_mode(global_settings.window_mode)
	DisplayServer.window_set_title(window_title)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_locale(global_settings.locale)
	
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			pause_game()
		else:
			unpause_game()
			
	if Input.is_action_just_pressed("map1"):
		WorldNode.load_map("test_map.tscn")
	elif Input.is_action_just_pressed("map2"):
		WorldNode.load_map("test_map2.tscn")
	
func _exit_tree():
	save_settings()
