extends "translator.gd"


func update(_delta: float) -> void:
	var positions: Array = tables[Position]
	var proxies: Array = tables[Proxy]
	for subscriber in subscribers: proxies[subscriber].translation = positions[subscriber]
