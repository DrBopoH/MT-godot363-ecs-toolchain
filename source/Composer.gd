class_name Composer
extends Reference

var components: Components = Components.new()
var requests: Requests = Requests.new()
var pipelines: Dictionary
var expiring: Array = []


func _init(_pipelines: Dictionary) -> void: pipelines = _pipelines


func flush() -> void:
	var expired: Array = expiring
	expiring = []
	for id in expired: kill(id)
	for values in requests.spawning: spawn(values)
	requests.spawning.clear()
	for entry in requests.appearing: add(entry[0], entry[1])
	requests.appearing.clear()
	for id in requests.dying: kill(id)
	requests.dying.clear()


func adopt(system: Functor) -> void:
	for id in components.count:
		if fits(system, id): subscribe(system, id)

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
	if components.events.has(key) and not expiring.has(id): expiring.append(id)
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if system.needs().has(key) and fits(system, id): subscribe(system, id)

func remove(id: int, component: GDScript) -> void:
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if system.needs().has(component) and fits(system, id): unsubscribe(system, id)
	components.table(component)[id] = null

func kill(id: int) -> void:
	if components.free.has(id): return
	for link in components.links:
		var referrers: Array = components.tables[link]
		for referrer in components.count:
			if referrers[referrer] == id: remove(referrer, link)
	for pipeline in pipelines.values():
		for system in pipeline.systems:
			if fits(system, id): unsubscribe(system, id)
	for component in components.tables: components.tables[component][id] = null
	components.release(id)
