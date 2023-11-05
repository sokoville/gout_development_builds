extends StaticBody3D


func _physics_process(delta):
	self.position.x = lerp(self.position.x, self.position.x - 2, delta * 2)
	
