class_name Pipeline
extends Reference

var positions: Dictionary = {}
var systems: Array = []


func open(position: GDScript, system: Reference) -> void:
	positions[position] = systems.size()
	systems.append(system)

func swap(position: GDScript, system: Reference) -> void:
	systems[positions[position]] = system


func update(delta: float) -> void:
	for system in systems: system.update(delta)
