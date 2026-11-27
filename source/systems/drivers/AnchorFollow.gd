class_name AnchorFollow
extends Following


func update(_delta: float) -> void:
	var positions: Array = tables[Position]
	var targets: Array = tables[Target]
	var offsets: Array = tables[Offset]
	for subscriber in subscribers: positions[subscriber] = positions[targets[subscriber]] + offsets[subscriber]
