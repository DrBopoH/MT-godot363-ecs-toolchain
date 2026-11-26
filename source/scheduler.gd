class_name Scheduler
extends Reference

var components: Components = Components.new()
var physic: Pipeline = Pipeline.new()
var render: Pipeline = Pipeline.new()


func physic(delta: float) -> void: physic.update(delta)

func render(delta: float) -> void: render.update(delta)


func open(pipeline: Pipeline, position: GDScript, system: Functor) -> void:
	bind(system)
	pipeline.open(position, system)

func bind(system: Functor) -> void:
	for component in system.needs(): system.tables[component] = components.declare(component)
