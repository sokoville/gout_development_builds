extends StaticBody3D

@onready var mesh = $MeshInstance3D
@onready var audio_player = $AudioStreamPlayer3D
@onready var light = $OmniLight3D

@export var health : int = 10
@export var audio : AudioStream = null

func _ready():
	self.set_meta("interactable", true)
	self.set_meta("enemy", true)
	audio_player.stream = audio

func interact(_player):
	audio_player.playing = not audio_player.playing
	light.light_energy = float(audio_player.playing) / 2

func _damage(damage) -> void:
	if damage >= health:
		audio_player.stream = null
		light.omni_range = 0
	else:
		health -= damage
