extends Node

const BulletHole = preload("res://scenes/bullet_hole.tscn")
const BulletScene = preload("res://scenes/bullet.tscn")

@export var gun_list = {
	"Pistol" = {
		primary_fire = {
			fire_rate = 0.15,
			accepted_input = "press",
			animation_name = "single_fire",
			damage = 25
		},
		
		secondary_fire = {
			fire_rate = 0.05,
			accepted_input = "hold",
			animation_name = "automatic_fire",
			damage = 12
		},
		
		model = load("res://scenes/pistol.tscn"),
		ammo_type = "pistol_ammo",
		mag_size = 15,
		reload_time = 1
	},
	
	"MP5" = {
		primary_fire = {
			fire_rate = 0.075,
			accepted_input = "hold",
			animation_name = "fire",
			damage = 20
		},
		
		model = load("res://scenes/mp5.tscn"),
		ammo_type = "smg_ammo",
		mag_size = 30,
		reload_time = 1
	}
}

@export var max_bullet_holes : int = 64

static var Map = null
static var Player : CharacterBody3D = null
static var FireRateTimer : Timer = Timer.new()
static var Camera : Camera3D = null
static var bullet_holes = []

func _setup(player_ref):
	Player = player_ref
	Player.add_child(FireRateTimer)
	Camera = Player.get_node("Head/Camera")
	FireRateTimer.one_shot = true
	Map = Player.get_node("/root/Game/3D/World").get_node(Player.get_node("/root/Game/3D/World").get_meta("map"))
	update_gun(0)
	
func spawn_bullet_hole(parent, position, normal):
	if bullet_holes.size() - 1 > max_bullet_holes:
		bullet_holes.pop_front().queue_free()
		
	var new_bullet_Hole = BulletHole.instantiate()
	parent.add_child(new_bullet_Hole)
	new_bullet_Hole.global_position = position
	new_bullet_Hole.look_at(position + normal, Vector3.UP)
	new_bullet_Hole.rotation.x += 90 # JUST ADD A NODE3D PARENT TO THE BULLET HOLE THATS ROTATED 90* on the X
	bullet_holes.append(new_bullet_Hole)

func fire(wait_time, animation_name, damage):
	if FireRateTimer.time_left == 0 and Player.equipped_weapons[Player.weapons_slot][1] != 0:
		Player.get_node("Head/Camera/Hand").get_node(Player.equipped_weapons[Player.weapons_slot][0]).get_node("AnimationPlayer").play(animation_name)
		Player.equipped_weapons[Player.weapons_slot][1] -= 1
		FireRateTimer.wait_time = wait_time
		FireRateTimer.start()
		
		var newBullet = BulletScene.instantiate()
		Camera.add_child(newBullet)
		newBullet.target_position = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), -50)
		newBullet.force_raycast_update()
		
		print(newBullet)
		print(newBullet.get_parent())
		print(newBullet.is_colliding())
		print(newBullet.position)
		if newBullet.is_colliding():
			var collider = newBullet.get_collider()
			spawn_bullet_hole(collider, newBullet.get_collision_point(), newBullet.get_collision_normal())
			
			if collider.has_meta("enemy"):
				newBullet.get_collider().call("_damage", damage)
				
		newBullet.queue_free()
			
		var head_rotation = Player.get_node("Head").rotation
		head_rotation.x += randf_range(0, 0.035)
		Player.create_tween().tween_property(Player.get_node("Head"), "rotation", head_rotation, 0.025)

func handle_primary_fire(input_type):
	if Player.equipped_weapons[Player.weapons_slot][0] != "empty":
		var weapon_info = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].primary_fire
		if input_type == "hold":
			if weapon_info.accepted_input != "press":
				fire(weapon_info.fire_rate, weapon_info.animation_name, weapon_info.damage)
		else:
			fire(weapon_info.fire_rate, weapon_info.animation_name, weapon_info.damage)
	
func handle_secondary_fire(input_type):
	if Player.equipped_weapons[Player.weapons_slot][0] != "empty":
		if gun_list[Player.equipped_weapons[Player.weapons_slot][0]].has("secondary_fire"):
			var weapon_info = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].secondary_fire
			if input_type == "hold":
				if weapon_info.accepted_input != "press":
					fire(weapon_info.fire_rate, weapon_info.animation_name, weapon_info.damage)
			else:
				fire(weapon_info.fire_rate, weapon_info.animation_name, weapon_info.damage)
	
func handle_reload():
	var weapon_ammo = Player.equipped_weapons[Player.weapons_slot][1]
	var mag_size = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].mag_size
	var ammo_type = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].ammo_type
	if weapon_ammo != mag_size and weapon_ammo != Player.ammo[ammo_type] and Player.ammo[ammo_type] != 0 and mag_size >= 0:
		FireRateTimer.wait_time = gun_list[Player.equipped_weapons[Player.weapons_slot][0]].reload_time
		Player.ammo[ammo_type] += weapon_ammo
		if Player.ammo[ammo_type] > mag_size:
			Player.equipped_weapons[Player.weapons_slot][1] = mag_size
			Player.ammo[ammo_type] -= mag_size
		else:
			Player.equipped_weapons[Player.weapons_slot][1] = Player.ammo[ammo_type]
			Player.ammo[ammo_type] = 0
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
			Player.get_node("Head/Camera/Hand").add_child(newGun)
			
		Player.weapons_slot = slot
