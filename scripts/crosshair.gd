extends TextureRect

var hand_crosshair = preload("res://textures/crosshair_hand_over.png")
var gun_crosshair = preload("res://textures/crosshair_gun.png")

@onready var Player : CharacterBody3D = get_parent().get_parent()
@onready var InteractionCheck : RayCast3D = Player.get_node("Head/Camera/InteractionCheck")

@onready var World : Node3D = Player.get_parent()

func _process(_delta):
	if InteractionCheck.is_colliding() and InteractionCheck.get_collider() != null and InteractionCheck.get_collider().has_meta("interactable"):
		texture = hand_crosshair
	elif Player.equipped_weapons[Player.weapons_slot][0] != "empty":
		texture = gun_crosshair
	else:
		texture = null
