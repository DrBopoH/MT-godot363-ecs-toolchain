class_name Components
extends Reference

var capacity: int = 1024
var count: int = 0
var tables: Dictionary = {}


func declare(component: GDScript) -> Array:
	var table: Array = []
	table.resize(capacity)
	tables[component] = table
	return table

func table(component: GDScript) -> Array:
	return tables[component]


func spawn() -> int:
	var id: int = count
	count+= 1
	return id
