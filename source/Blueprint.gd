class_name Blueprint
extends Resource

var carriers: Array = []
var cursor: int = 0


func _iter_init(_state) -> bool:
	cursor = 0
	return cursor < carriers.size()

func _iter_next(_state) -> bool:
	cursor+= 1
	return cursor < carriers.size()

func _iter_get(_state): return carriers[cursor]
