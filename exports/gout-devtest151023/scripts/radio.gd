extends StaticBody3D

@onready var mesh = $MeshInstance3D
@onready var audio = $AudioStreamPlayer3D
@onready var light = $OmniLight3D

func _ready():
	self.set_meta("interactable", true)

func interact():
	audio.playing = not audio.playing
	light.light_energy = float(audio.playing) / 2

func _damage(_damage) -> void:
	audio.stream = null
	light.omni_range = 0
