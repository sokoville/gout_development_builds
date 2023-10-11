extends Control

@onready var GameNode : Node = get_node("/root/Game")
@onready var World : Node3D = get_node("/root/Game/3D/World")
@onready var Player : CharacterBody3D = World.get_node(World.get_meta("map")).get_node("Player")

@onready var uiFPSCounter : RichTextLabel = $VBoxContainer/FPSCounter
@onready var uiGameTitle : RichTextLabel = $VBoxContainer/GameTitle
@onready var uiMemoryUsage : RichTextLabel = $VBoxContainer/MemoryUsage
@onready var uiVRamUsage : RichTextLabel = $VBoxContainer/VRamUsage
@onready var uiObjectCount : RichTextLabel = $VBoxContainer/ObjectCount
@onready var uiPlayerPosition : RichTextLabel = $VBoxContainer/PlayerPosition
@onready var uiCurrentMap : RichTextLabel = $VBoxContainer/CurrentMap
@onready var uiEquippedWeapons : RichTextLabel = $VBoxContainer/EquippedWeapons

func _ready():
	uiGameTitle.set_text(GameNode.app_name + " " + GameNode.version + " / " + GameNode.engine_version + " / " + GameNode.renderer_version)
	
	if OS.is_debug_build():
		self.visible = true

func _input(_event):
	if Input.is_action_just_pressed("ui_filedialog_refresh"):
		self.visible = not self.visible
		
func _process(_delta):
	if self.visible == false:
		return

	uiFPSCounter.set_text(str(Performance.get_monitor(Performance.TIME_FPS)) + " fps in ~" + str(Performance.get_monitor(Performance.TIME_PROCESS)) + " seconds \n ")
	
	uiMemoryUsage.set_text("Memory: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC) / 10000) / 10) + " MB / " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 10000) / 10) + " MB" )
	uiVRamUsage.set_text("Video Memory: " + str(round(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED ) / 10000) / 10) + " MB")
	uiObjectCount.set_text("Object Count: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) + " (Physics Objects: " + str(Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS)) + ") \n ")
	
	uiCurrentMap.set_text("Current Map: " + str(World.get_meta("map")))
	uiPlayerPosition.set_text("Player Position: (" + str(round(Player.global_position.x * 10) / 10) + ", " + str(round(Player.global_position.y * 10) / 10) + ", " + str(round(Player.global_position.x * 10) / 10) + ") \nPlayer Speed: " + str((round(Player.current_speed * 10)) / 10) + " / " + str(Player.max_speed))
	uiEquippedWeapons.set_text("Equipped Weapon: " + str(Player.equipped_weapons[Player.weapons_slot][0]) + " (" + str(Player.equipped_weapons[Player.weapons_slot][1]) + ") (" + str(Player.equipped_weapons[0][0]) + ", " + Player.equipped_weapons[1][0] + ", " + Player.equipped_weapons[2][0] + ")")