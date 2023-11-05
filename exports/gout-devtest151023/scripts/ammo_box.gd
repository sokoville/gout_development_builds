extends Area3D

func _on_body_entered(body):
	if body.name == "Player":
		body.ammo[self.get_meta("type")] += 20
		
		if body.current_ammo_type == self.get_meta("type"):
			body.reload(false)
	self.queue_free()
