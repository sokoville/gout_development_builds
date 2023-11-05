extends GDShellCommand


func _main(argv: Array, data) -> Dictionary:
	var out: String = ""
	
	if data != null:
		out = str(data)
	elif argv.size() > 1:
		output(" ".join(argv.slice(1)))
	
	if not out.is_empty():
		output(out)
	
	@warning_ignore("incompatible_ternary")
	return {"data": null if out.is_empty() else out}
