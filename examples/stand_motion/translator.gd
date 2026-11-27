extends Functor

const Position = preload("position.gd")
const Proxy = preload("proxy.gd")


func needs() -> Array: return [Position, Proxy]

func rate() -> int: return RENDER
