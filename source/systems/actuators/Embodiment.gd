class_name Embodiment
extends Functor


func needs() -> Array: return [Scene]

func owns() -> Array: return [Root]

func uses() -> Array: return [Proxy]

func rate() -> int: return RENDER

func exit(entity: int) -> void: tables[Proxy][entity].queue_free()
