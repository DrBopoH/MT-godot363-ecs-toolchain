class_name Scheduler
extends Reference

var components: Components = Components.new()
var physic: Pipeline = Pipeline.new()
var render: Pipeline = Pipeline.new()
var pipelines: Dictionary = {Functor.PHYSIC: physic, Functor.RENDER: render}
var requests: Requests = Requests.new()


func physic(delta: float) -> void:
	physic.update(delta)
	for values in requests.spawning: spawn(values)
	requests.spawning.clear()
	for entry in requests.appearing: add(entry[0], entry[1])
	requests.appearing.clear()
	for id in requests.dying: kill(id)
	requests.dying.clear()

func render(delta: float) -> void: render.update(delta)


func open(position: GDScript, system: Functor, values: Array) -> void:
	system.id = components.spawn()
	bind(system)
	for component in values: system.tables[component.get_script()][system.id] = component.value
	for id in components.count:
		if fits(system, id): subscribe(system, id)
	pipelines[system.rate()].open(position, system)

func swap(position: GDScript, system: Functor) -> void:
	var old: Functor = pipelines[system.rate()].swap(position, system)
	system.id = old.id
	system.subscribers = old.subscribers
	bind(system)

func bind(system: Functor) -> void:
	for component in system.needs() + system.owns() + system.uses(): system.tables[component] = components.declare(component)
	system.requests = requests

func fits(system: Functor, id: int) -> bool:
	if system.needs().empty(): return false
	for component in system.needs():
		if system.tables[component][id] == null: return false
	return true

func subscribe(system: Functor, id: int) -> void:
	system.subscribers.append(id)
	system.enter(id)

func unsubscribe(system: Functor, id: int) -> void:
	system.exit(id)
	system.subscribers.erase(id)


func spawn(values: Array) -> int:
	var id: int = components.spawn()
	for component in values: add(id, component)
	return id

func add(id: int, component: Reference) -> void:
	var key: GDScript = component.get_script()
	components.declare(key)[id] = component.value
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if system.needs().has(key) and fits(system, id): subscribe(system, id)

func remove(id: int, component: GDScript) -> void:
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if system.needs().has(component) and fits(system, id): unsubscribe(system, id)
	components.table(component)[id] = null

func kill(id: int) -> void:
	for link in components.links:
		var referrers: Array = components.tables[link]
		for referrer in components.count:
			if referrers[referrer] == id: remove(referrer, link)
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if fits(system, id): unsubscribe(system, id)
	for component in components.tables: components.tables[component][id] = null
	components.release(id)
