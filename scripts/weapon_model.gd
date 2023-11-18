extends Node3D

var state = null
var spin_tween = null

func set_visibility_layer(layer : int):
	for child in self.get_children():
		if child is MeshInstance3D:
			if layer == 1:
				child.set_layer_mask_value(1, true)
				child.set_layer_mask_value(2, false)
			elif layer == 2:
				child.set_layer_mask_value(1, false)
				child.set_layer_mask_value(2, true)
			else:
				print("Invalid layer")

func setup(setup_state : String):
	state = setup_state
	if state == "viewmodel":
		if self.has_node("Skeleton3D"):
			$Skeleton3D.visible = true
		if self.has_node("PickupArea"):
			$PickupArea.queue_free()
		set_visibility_layer(2)
	elif state == "pickup":
		var pickup_area = Area3D.new()
		var collision_shape = CollisionShape3D.new()
		pickup_area.name = "PickupArea"
		collision_shape.shape = BoxShape3D.new()
		collision_shape.shape.size = Vector3(5, 5, 5)
		pickup_area.add_child(collision_shape)
		self.add_child(pickup_area)
		pickup_area.global_position = self.global_position
		pickup_area.set_collision_mask_value(1, false)
		pickup_area.set_collision_mask_value(2, true)
		set_visibility_layer(1)
		spin_tween = get_tree().create_tween()
		spin_tween.set_loops()
		spin_tween.tween_property(self, "rotation_degrees", Vector3(self.rotation_degrees.x, 360, self.rotation_degrees.z), 2.5).as_relative()

func _exit_tree():
	if spin_tween != null:
		spin_tween.kill()
		
func _ready():
	if not self.get_parent().get_parent().is_class("Camera3D"):
		setup("pickup")
		
func _process(_delta):
	if state == "pickup":
		if self.has_node("PickupArea"):
			if self.get_node("PickupArea").has_overlapping_bodies():
				print("Over")
				if self.get_node("PickupArea").get_overlapping_bodies()[0].name == "Player":
					var Player = self.get_node("PickupArea").get_overlapping_bodies()[0]
					var has_weapon = false
					for n in Player.equipped_weapons.size():
						if Player.equipped_weapons[n][0] == self.get_meta("name"):
							has_weapon = true
							
					if not has_weapon:
						for n in Player.equipped_weapons.size():
							if Player.equipped_weapons[n][0] == "empty":
								Player.equipped_weapons[n][0] = self.get_meta("name")
								Player.equipped_weapons[n][1] = self.get_meta("mag_size")
								Player.switch_gun(n)
								break
								
						self.queue_free()
						
