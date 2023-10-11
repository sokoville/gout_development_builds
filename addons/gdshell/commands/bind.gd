extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv : Array, data):
	if argv.size() == 3:
		if InputMap.has_action(argv[1]):
			var input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(argv[2])
			InputMap.action_add_event(argv[1], input_event)
			output(str(argv[1]) + " bound to " + argv[2])
		else:
			output("No action found")
	elif argv.size() == 4:
		if InputMap.has_action(argv[1]):
			if argv[2] == "mouse" or argv[2] == "Mouse":
				var input_event = InputEventMouseButton.new()
				input_event.button_index = int(argv[3])
				InputMap.action_add_event(argv[1], input_event)
				output(str(argv[1]) + " bound to Mouse" + argv[3])
			else:
				output("Too many args for not binding to a mouse")
		else:
			output("No action found")
	else:
		output("Not enough args; bind [action_name] [key] OR bind [action_name] mouse [mouse_button]")
	return {}
