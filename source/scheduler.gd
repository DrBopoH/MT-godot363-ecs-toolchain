class_name Scheduler
extends Reference

var components: Components = Components.new()
var physic: Pipeline = Pipeline.new()
var render: Pipeline = Pipeline.new()
var pipelines: Dictionary = {Functor.PHYSIC: physic, Functor.RENDER: render}


func physic(delta: float) -> void: physic.update(delta)

func render(delta: float) -> void: render.update(delta)


func open(position: GDScript, system: Functor) -> void:
	bind(system)
	pipelines[system.rate()].open(position, system)

func bind(system: Functor) -> void:
	for component in system.needs(): system.tables[component] = components.declare(component)
