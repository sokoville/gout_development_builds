extends Node

const BulletHole = preload("res://scenes/prefabs/decals/bullet_hole.tscn")
const BulletScene = preload("res://scenes/systems/bullet.tscn")

@export var gun_list = {
	"Pistol" = {
		primary_fire = {
			fire_rate = 0.15,
			accepted_input = "press",
			animation_name = "single_fire",
			bullets_per_shot = 1,
			damage = 25,
			range = 1000,
			v_recoil = [0, 0.035],
			spread = [-5, 5],
			shoot_sound = load("res://resources/sounds/pistol_shoot.wav")
		},
		
		secondary_fire = {
			fire_rate = 0.05,
			accepted_input = "hold",
			animation_name = "automatic_fire",
			bullets_per_shot = 1,
			damage = 12,
			range = 1000,
			v_recoil = [0.025, 0.075],
			spread = [-5, 5]
		},
		
		model = load("res://scenes/prefabs/weapons/pistol.tscn"),
		ammo_type = "inf",
		mag_size = 15,
		reload_time = 1
	},
	
	"MP5" = {
		primary_fire = {
			fire_rate = 0.075,
			accepted_input = "hold",
			animation_name = "fire",
			bullets_per_shot = 1,
			damage = 20,
			range = 1000,
			v_recoil = [0, 0.035],
			spread = [-5, 5]
		},
		
		model = load("res://scenes/prefabs/weapons/mp5.tscn"),
		ammo_type = "pistol_ammo",
		mag_size = 30,
		reload_time = 1
	},
	
	"PumpShotgun" = {
		primary_fire = {
			fire_rate = 0.075,
			accepted_input = "press",
			animation_name = "fire",
			bullets_per_shot = 6,
			damage = 16,
			range = 1000,
			v_recoil = [0.025, 0.05],
			spread = [-200, 200]
		},
		
		model = load("res://scenes/prefabs/weapons/pump_shotgun.tscn"),
		ammo_type = "shotgun_ammo",
		mag_size = 6,
		reload_time = 1
	}
}

@export var max_bullet_holes : int = 64

var Player : CharacterBody3D = null
var FireRateTimer : Timer = Timer.new()
var Camera : Camera3D = null
var World : Node3D = null
var StatusUI = null

var recoil_to_inact = 0

func _setup(player_ref):
	Player = player_ref
	Player.add_child(FireRateTimer)
	World = Player.get_node("/root/Game/3D/World")
	print(World)
	StatusUI = Player.get_node("UI/Status")
	Camera = Player.get_node("Head/Camera")
	FireRateTimer.one_shot = true
	update_gun(0)
	
func spawn_bullet_hole(parent, position, normal):
	if World.bullet_holes.size() - 1 > max_bullet_holes:
		World.bullet_holes.pop_front().queue_free()
		
	var new_bullet_Hole = BulletHole.instantiate()
	parent.add_child(new_bullet_Hole)
	new_bullet_Hole.global_position = position
	if normal != Vector3.UP and normal != Vector3.DOWN:
		new_bullet_Hole.look_at(position + normal, Vector3.UP)
	new_bullet_Hole.rotation.x += 90
	World.bullet_holes.append(new_bullet_Hole)

func fire_sound(_weapon_info):
	var audio_player = AudioStreamPlayer3D.new()
	Player.add_child(audio_player)
	audio_player.stream = load("res://resources/sounds/pistol_shoot.wav")
	audio_player.volume_db = -35
	audio_player.play()
	var free_queue = func():
		audio_player.queue_free()
	
	audio_player.finished.connect(free_queue)

func bullet(weapon_info):
	var newBullet = BulletScene.instantiate()
	Camera.add_child(newBullet)
	newBullet.target_position = Vector3(randf_range(weapon_info.spread[0], weapon_info.spread[1]), randf_range(weapon_info.spread[0], weapon_info.spread[1]), -weapon_info.range)
	newBullet.force_raycast_update()
	
	if newBullet.is_colliding():
		var collider = newBullet.get_collider()
		spawn_bullet_hole(collider, newBullet.get_collision_point(), newBullet.get_collision_normal())
		
		if collider.has_meta("enemy"):
			newBullet.get_collider().call("_damage", weapon_info.damage)
			
	newBullet.queue_free()

func fire(weapon_info):
	if FireRateTimer.time_left == 0 and Player.equipped_weapons[Player.weapons_slot][1] != 0:
		Player.get_node("Head/Camera/Hand").get_node(Player.equipped_weapons[Player.weapons_slot][0]).get_node("AnimationPlayer").play(weapon_info.animation_name)
		Player.equipped_weapons[Player.weapons_slot][1] -= 1
		FireRateTimer.wait_time = weapon_info.fire_rate
		FireRateTimer.start()
		
		for count in range(weapon_info.bullets_per_shot):
			bullet(weapon_info)
			
		fire_sound(weapon_info)
		StatusUI.update_ammo(Player.equipped_weapons[Player.weapons_slot][1], Player.ammo[gun_list[Player.equipped_weapons[Player.weapons_slot][0]].ammo_type])
		var head_rotation = Player.get_node("Head").rotation
		head_rotation.x += randf_range(weapon_info.v_recoil[0], weapon_info.v_recoil[1])
		Player.create_tween().tween_property(Player.get_node("Head"), "rotation", head_rotation, 0.025)

func handle_primary_fire(input_type):
	if Player.equipped_weapons[Player.weapons_slot][0] != "empty":
		var weapon_info = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].primary_fire
		if input_type == "hold":
			if weapon_info.accepted_input != "press":
				fire(weapon_info)
		else:
			fire(weapon_info)
	
func handle_secondary_fire(input_type):
	if Player.equipped_weapons[Player.weapons_slot][0] != "empty":
		if gun_list[Player.equipped_weapons[Player.weapons_slot][0]].has("secondary_fire"):
			var weapon_info = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].secondary_fire
			if input_type == "hold":
				if weapon_info.accepted_input != "press":
					fire(weapon_info)
			else:
				fire(weapon_info)
	
func handle_reload(should_animate):
	if Player.equipped_weapons[Player.weapons_slot][0] != "empty":
		var weapon_ammo = Player.equipped_weapons[Player.weapons_slot][1]
		var mag_size = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].mag_size
		var ammo_type = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].ammo_type
		if weapon_ammo != mag_size and weapon_ammo != Player.ammo[ammo_type] and Player.ammo[ammo_type] != 0 and mag_size >= 0:
			FireRateTimer.wait_time = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].reload_time
			if Player.ammo[ammo_type] >= 0:
				Player.ammo[ammo_type] += weapon_ammo
			if Player.ammo[ammo_type] > mag_size:
				Player.equipped_weapons[Player.weapons_slot][1] = mag_size
				Player.ammo[ammo_type] -= mag_size
			elif Player.ammo[ammo_type] == -1:
				Player.equipped_weapons[Player.weapons_slot][1] = mag_size
			else:
				Player.equipped_weapons[Player.weapons_slot][1] = Player.ammo[ammo_type]
				Player.ammo[ammo_type] = 0
				
			StatusUI.update_ammo(Player.equipped_weapons[Player.weapons_slot][1], Player.ammo[gun_list[Player.equipped_weapons[Player.weapons_slot][0]].ammo_type])
				
			if should_animate:
				Player.get_node("Head/Camera/Hand").get_node(Player.equipped_weapons[Player.weapons_slot][0]).get_node("AnimationPlayer").play("reload")
				FireRateTimer.start()
			

func update_gun(slot):
	if slot != Player.weapons_slot:
		var equipped_gun = Player.equipped_weapons[Player.weapons_slot][0]
		var gun_to_equip = Player.equipped_weapons[slot][0]
		
		if Player.get_node("Head/Camera/Hand").has_node(equipped_gun):
			Player.get_node("Head/Camera/Hand").get_node(equipped_gun).queue_free()
		
		if gun_to_equip != "empty":
			var newGun = gun_list[gun_to_equip].model.instantiate()
			newGun.setup("viewmodel")
			Player.get_node("Head/Camera/Hand").add_child(newGun)
			Player.current_ammo_type = gun_list[gun_to_equip].ammo_type
			StatusUI.update_ammo(Player.equipped_weapons[slot][1], Player.ammo[gun_list[Player.equipped_weapons[slot][0]].ammo_type])
		else:
			StatusUI.update_ammo(-1, -1)
			
		Player.last_slot = Player.weapons_slot
		Player.weapons_slot = slot
