class_name Movement
extends Functor


func needs() -> Array: return [Position, Velocity]

func rate() -> int: return PHYSIC
