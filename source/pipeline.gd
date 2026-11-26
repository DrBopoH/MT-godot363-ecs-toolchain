class_name Pipeline
extends Reference

var positions: Dictionary = {}
var systems: Array = []


func open(position: GDScript, system: Reference) -> void:
	positions[position] = systems.size()
	systems.append(system)

func swap(position: GDScript, system: Reference) -> Reference:
	var old: Reference = systems[positions[position]]
	systems[positions[position]] = system
	return old


func update(delta: float) -> void:
	for system in systems: system.update(delta)
