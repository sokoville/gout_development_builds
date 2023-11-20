extends Control

@onready var LanguageSelect = $TempSettings/LanguageSelect
@onready var Game = get_node("/root/Game")

var languages = ["en", "nl", "ru"]

func _ready():
	self.visible = false

func load_menu():
	LanguageSelect.selected = languages.bsearch(Game.global_settings.locale)
	self.visible = true


func _on_language_select_item_selected(option):
	Game.set_locale(languages[option])


func _on_quit_button_pressed():
	get_tree().quit() 

func _on_resume_button_pressed():
	Game.unpause_game()
