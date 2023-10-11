extends CharacterBody3D

@export var health : float = 100

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _damage(amount):
	if health > 0:
		health -= amount
		
		if health <= 0:
			look_at(get_node("/root/Game/3D/World").get_node(get_node("/root/Game/3D/World").get_meta("map")).get_node("Player").global_position)
			create_tween().tween_property(self, "rotation", Vector3(deg_to_rad(90), rotation.y, rotation.z), 0.1)
			
			
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_and_collide(velocity)
