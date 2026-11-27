class_name LinearMovement
extends Movement


func update(delta: float) -> void:
	var positions: Array = tables[Position]
	var velocities: Array = tables[Velocity]
	for subscriber in subscribers: positions[subscriber]+= velocities[subscriber]*delta
