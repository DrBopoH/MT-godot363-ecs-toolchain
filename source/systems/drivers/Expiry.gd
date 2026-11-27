class_name Expiry
extends Aging


func update(delta: float) -> void:
	var lifetimes: Array = tables[Lifetime]
	for subscriber in subscribers:
		lifetimes[subscriber]-= delta
		if lifetimes[subscriber] <= 0.0: requests.dying.append(subscriber)
