class_name Components
extends Reference

var capacity: int = 1024
var count: int = 0
var tables: Dictionary = {}
var free: Array = []
var links: Array = []


func declare(component: GDScript) -> Array:
	if not tables.has(component):
		var table: Array = []
		table.resize(capacity)
		tables[component] = table
		if component.get_base_script() == Link: links.append(component)
	return tables[component]

func table(component: GDScript) -> Array:
	return tables[component]


func spawn() -> int:
	if not free.empty(): return free.pop_back()
	var id: int = count
	count+= 1
	return id

func release(id: int) -> void: free.append(id)
