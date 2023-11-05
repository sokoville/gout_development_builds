extends Node3D

func _ready():
	self.set_meta("interactable", true)

func interact(player):
	player.ammo[self.get_meta("type")] += 20
		
	if player.current_ammo_type == self.get_meta("type"):
		player.reload(false)
	self.queue_free()

func _on_ammo_box_body_entered(body):
	if body.name == "Player":
		body.ammo[self.get_meta("type")] += 20
		
		if body.current_ammo_type == self.get_meta("type"):
			body.reload(false)
		self.queue_free()
