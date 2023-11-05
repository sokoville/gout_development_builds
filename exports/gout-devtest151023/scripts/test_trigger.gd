extends Area3D

@onready var AnnouncementText : RichTextLabel = get_node("/root/Game/2D/UI/Control/AnnoucementHBox/AnnouncementText")
@onready var MeshInstance : MeshInstance3D = $MeshInstance3D

func _ready():
	if not OS.has_feature("editor"):
		MeshInstance.queue_free()

func _on_body_entered(_body):
	AnnouncementText.set_text("VERY SCARY TEST TRIGGER LOCATION")


func _on_body_exited(_body):
	AnnouncementText.set_text("")
	self.queue_free()
