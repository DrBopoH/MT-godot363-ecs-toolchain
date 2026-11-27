class_name Periodic
extends Emission


func update(delta: float) -> void:
	tables[Countdown][id]-= delta
	if tables[Countdown][id] > 0.0: return
	tables[Countdown][id]+= tables[Interval][id]
	requests.spawning.append(tables[Template][id])
