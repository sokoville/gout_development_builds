extends Control

@onready var AmmoCounter = $Ammo/Counter
@onready var ArmourCounter = $Health/ArmourCounter
@onready var HealthCounter = $Health/HealthCounter

func update_ammo(current_ammo, max_ammo):
	AmmoCounter.clear()
	if current_ammo != -1:
		if max_ammo != -1:
			AmmoCounter.add_text(str(current_ammo) + " | " + str(max_ammo))
		else:
			AmmoCounter.add_text(str(current_ammo))
	
func update_health(health, armour):
	ArmourCounter.clear()
	HealthCounter.clear()
	
	HealthCounter.add_text("H: " + str(health))
	ArmourCounter.add_text("A: " + str(armour))
