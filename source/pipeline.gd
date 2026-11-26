class_name Pipeline
extends Reference

var positions: Dictionary = {}
var systems: Array = []


func open(position: String, system: Reference) -> void:
	positions[position] = systems.size()
	systems.append(system)

func swap(position: String, system: Reference) -> void:
	systems[positions[position]] = system


func update(components: Components, delta: float) -> void:
	for system in systems: system.update(components, delta)
