class_name Scheduler
extends Reference

var components: Components = Components.new()
var physic: Pipeline = Pipeline.new()
var render: Pipeline = Pipeline.new()
var pipelines: Dictionary = {Functor.PHYSIC: physic, Functor.RENDER: render}
var dying: Array = []


func physic(delta: float) -> void:
	physic.update(delta)
	for id in dying: kill(id)
	dying.clear()

func render(delta: float) -> void: render.update(delta)


func open(position: GDScript, system: Functor, values: Dictionary) -> void:
	system.id = components.spawn()
	bind(system)
	for component in values: system.tables[component][system.id] = values[component]
	for id in components.count:
		if fits(system, id): subscribe(system, id)
	pipelines[system.rate()].open(position, system)

func swap(position: GDScript, system: Functor) -> void:
	var old: Functor = pipelines[system.rate()].swap(position, system)
	system.id = old.id
	system.subscribers = old.subscribers
	bind(system)

func bind(system: Functor) -> void:
	for component in system.needs() + system.owns(): system.tables[component] = components.declare(component)
	system.dying = dying

func fits(system: Functor, id: int) -> bool:
	for component in system.needs():
		if system.tables[component][id] == null: return false
	return true

func subscribe(system: Functor, id: int) -> void:
	system.subscribers.append(id)
	system.enter(id)

func unsubscribe(system: Functor, id: int) -> void:
	system.exit(id)
	system.subscribers.erase(id)


func spawn(values: Dictionary) -> int:
	var id: int = components.spawn()
	for component in values: add(id, component, values[component])
	return id

func add(id: int, component: GDScript, value) -> void:
	components.declare(component)[id] = value
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if system.needs().has(component) and fits(system, id): subscribe(system, id)

func remove(id: int, component: GDScript) -> void:
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if system.needs().has(component) and fits(system, id): unsubscribe(system, id)
	components.table(component)[id] = null

func kill(id: int) -> void:
	for component in components.tables:
		if components.tables[component][id] != null: remove(id, component)
