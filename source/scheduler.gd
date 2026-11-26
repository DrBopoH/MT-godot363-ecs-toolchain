class_name Scheduler
extends Reference

var components: Components = Components.new()
var physic: Pipeline = Pipeline.new()
var render: Pipeline = Pipeline.new()
var pipelines: Dictionary = {Functor.PHYSIC: physic, Functor.RENDER: render}
var systems: Array = []


func physic(delta: float) -> void: physic.update(delta)

func render(delta: float) -> void: render.update(delta)


func open(position: GDScript, system: Functor, values: Dictionary) -> void:
	system.id = components.spawn()
	bind(system)
	for component in values: system.tables[component][system.id] = values[component]
	systems.append(system)
	pipelines[system.rate()].open(position, system)

func bind(system: Functor) -> void:
	for component in system.needs() + system.owns(): system.tables[component] = components.declare(component)


func spawn(values: Dictionary) -> int:
	var id: int = components.spawn()
	for component in values: components.declare(component)[id] = values[component]
	for system in systems:
		if values.has_all(system.needs()): system.subscribers.append(id)
	return id
