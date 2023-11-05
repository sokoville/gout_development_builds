extends StaticBody3D

@onready var CollisionShape = $CollisionShape3D 

@export var speed : int = 250
@export var default_state : String = "closed"

var open_state : String = default_state
var last_rotation = self.rotation_degrees.y
var last_state = "closed"
var next_state = null
var tween = null

func _ready():
	self.set_meta("interactable", true)

func set_state():
	open_state = next_state

func rotate_door(state, rotatiod):
	if tween != null:
		tween.kill()
		
	if open_state != "changing":
		last_rotation = self.rotation_degrees.y
		last_state = open_state
	next_state = state
	tween = self.create_tween()
	tween.tween_property(self, "rotation_degrees", Vector3(0, rotatiod, 0), (abs(self.rotation_degrees.y - rotatiod) / speed))
	open_state = "changing"
	
	tween.finished.connect(set_state)
		
func interact(player):
	if open_state == "closed":
		var interaction_normal = player.get_node("Head/Camera/InteractionCheck").get_collision_normal()
		if interaction_normal.z > 0:
			rotate_door("open_positive", self.rotation_degrees.y + 90)
		else:
			rotate_door("open_negative", self.rotation_degrees.y + -90)
	elif open_state == "open_positive":
		rotate_door("closed", self.rotation_degrees.y + -90)
	elif open_state == "open_negative":
		rotate_door("closed", self.rotation_degrees.y + 90)
	elif open_state == "changing":
		rotate_door(last_state, last_rotation)
