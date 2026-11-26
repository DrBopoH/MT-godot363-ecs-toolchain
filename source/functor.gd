class_name Functor
extends Reference

enum {PHYSIC, RENDER}

var id: int = 0
var subscribers: Array = []
var tables: Dictionary = {}


func needs() -> Array: return []

func owns() -> Array: return []

func rate() -> int: return -1

func update(_delta: float) -> void: return
