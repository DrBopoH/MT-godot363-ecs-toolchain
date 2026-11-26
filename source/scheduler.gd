class_name Scheduler
extends Reference

var components: Components = Components.new()
var physic: Pipeline = Pipeline.new()
var render: Pipeline = Pipeline.new()


func physic(delta: float) -> void: physic.update(components, delta)

func render(delta: float) -> void: render.update(components, delta)
