extends Control

@onready var AmmoCounter = $Ammo/Counter
@onready var ArmourCounter = $Health/ArmourCounter/Counter
@onready var HealthCounter = $Health/HealthCounter/Counter

func update_ammo(current_ammo, max_ammo):
	AmmoCounter.clear()
	if current_ammo != -1:
		if max_ammo != -1:
			AmmoCounter.add_text(str(current_ammo) + " | " + str(max_ammo))
		else:
			AmmoCounter.add_text(str(current_ammo))
	
func update_health(health, armour):
	print(health, armour)
	
	HealthCounter.text = str(health)
	ArmourCounter.text = str(armour)
