class_name Functor
extends Reference

enum {PHYSIC, RENDER}

var id: int = 0
var subscribers: Array = []
var tables: Dictionary = {}
var dying: Array = []
var appearing: Array = []
var spawning: Array = []


func needs() -> Array: return []

func owns() -> Array: return []

func uses() -> Array: return []

func rate() -> int: return -1

func update(_delta: float) -> void: return

func enter(_id: int) -> void: return

func exit(_id: int) -> void: return
