extends Node

@export var app_name : String = "Gout"
@export var version : String = "devtest1"
@export var engine_version : String = "ERR engine_version not loaded"
@export var renderer_version : String = "ERR renderer_version not loaded"

func _init():
	engine_version = "Godot Engine " + Engine.get_version_info().string
	renderer_version = "Vulkan API " + RenderingServer.get_video_adapter_api_version()

func _ready():
	var debug = ""
	if OS.is_debug_build():
		debug = " DEBUG_BUILD"
		
	if OS.has_feature("editor"):
		var date = Time.get_date_dict_from_system()
		version = "devtest" + str(date.day) + str(date.month) + str(date.year - 2000) + " " + Time.get_time_string_from_system()
		
	var window_title = (app_name + " " + version + debug + " / " + engine_version + " / " + renderer_version)
	
	DisplayServer.window_set_title(window_title)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
