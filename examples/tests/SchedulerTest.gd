extends Reference

class Pos:
	extends Reference
	var value: float
	func _init(_value: float) -> void: value = _value

class Grav:
	extends Reference
	var value: float
	func _init(_value: float) -> void: value = _value

class Tag:
	extends Reference
	var value: bool
	func _init(_value: bool) -> void: value = _value

class Shift:
	extends Functor
	func needs() -> Array: return [Pos]
	func owns() -> Array: return [Grav]
	func rate() -> int: return PHYSIC
	func update(_delta: float) -> void:
		var positions: Array = tables[Pos]
		for subscriber in subscribers: positions[subscriber]+= tables[Grav][id]

class ReverseShift:
	extends Shift
	func update(_delta: float) -> void:
		var positions: Array = tables[Pos]
		for subscriber in subscribers: positions[subscriber]-= tables[Grav][id]

class Tagged:
	extends Functor
	func needs() -> Array: return [Pos, Tag]
	func rate() -> int: return PHYSIC

class Reaper:
	extends Functor
	func needs() -> Array: return [Pos]
	func rate() -> int: return PHYSIC
	func update(_delta: float) -> void:
		for subscriber in subscribers:
			if tables[Pos][subscriber] >= 4.0: dying.append(subscriber)

class Undertaker:
	extends Functor
	var seen: Array = []
	func needs() -> Array: return [Tag]
	func uses() -> Array: return [Pos]
	func rate() -> int: return RENDER
	func exit(id: int) -> void: seen.append([id, tables[Pos][id]])

class Tagger:
	extends Functor
	func needs() -> Array: return [Pos]
	func rate() -> int: return PHYSIC
	func update(_delta: float) -> void:
		for subscriber in subscribers:
			if tables[Pos][subscriber] >= 2.0: appearing.append([subscriber, Tag.new(true)])

class Witness:
	extends Functor
	var seen: Array = []
	func needs() -> Array: return [Pos]
	func rate() -> int: return RENDER
	func enter(id: int) -> void: seen.append(["enter", id, tables[Pos][id]])
	func exit(id: int) -> void: seen.append(["exit", id, tables[Pos][id]])




func test_spawn_subscribes_by_needs() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(2.0)])
	var moving: int = scheduler.spawn([Pos.new(0.0)])
	var still: int = scheduler.spawn([Tag.new(true)])
	scheduler.physic(0.0)
	return shift.subscribers == [moving] and scheduler.components.table(Pos)[moving] == 2.0 and scheduler.components.table(Tag)[still] == true

func test_open_subscribes_existing() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var early: int = scheduler.spawn([Pos.new(0.0)])
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(2.0)])
	var late: int = scheduler.spawn([Pos.new(10.0)])
	return shift.subscribers == [early, late]

func test_add_and_remove_resubscribe() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var tagged: Tagged = Tagged.new()
	scheduler.open(Tagged, tagged, [])
	var entity: int = scheduler.spawn([Pos.new(0.0)])
	var before: bool = tagged.subscribers.empty()
	scheduler.add(entity, Tag.new(true))
	var added: bool = tagged.subscribers == [entity]
	scheduler.remove(entity, Tag)
	return before and added and tagged.subscribers.empty() and scheduler.components.table(Tag)[entity] == null

func test_swap_keeps_id_params_and_subscribers() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(2.0)])
	var entity: int = scheduler.spawn([Pos.new(0.0)])
	scheduler.physic(0.0)
	var reverse: ReverseShift = ReverseShift.new()
	scheduler.swap(Shift, reverse)
	scheduler.physic(0.0)
	scheduler.physic(0.0)
	return reverse.id == shift.id and reverse.subscribers == [entity] and scheduler.components.table(Pos)[entity] == -2.0

func test_dying_kills_after_tick() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(2.0)])
	scheduler.open(Reaper, Reaper.new(), [])
	var doomed: int = scheduler.spawn([Pos.new(2.0), Tag.new(true)])
	var safe: int = scheduler.spawn([Pos.new(-10.0)])
	scheduler.physic(0.0)
	scheduler.physic(0.0)
	return shift.subscribers == [safe] and scheduler.components.table(Pos)[doomed] == null and scheduler.components.table(Tag)[doomed] == null

func test_enter_and_exit_see_data() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var witness: Witness = Witness.new()
	scheduler.open(Witness, witness, [])
	var entity: int = scheduler.spawn([Pos.new(3.0)])
	scheduler.remove(entity, Pos)
	return witness.seen == [["enter", entity, 3.0], ["exit", entity, 3.0]]

func test_appearing_adds_after_tick_before_dying() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var tagged: Tagged = Tagged.new()
	scheduler.open(Shift, Shift.new(), [Grav.new(2.0)])
	scheduler.open(Tagger, Tagger.new(), [])
	scheduler.open(Tagged, tagged, [])
	var entity: int = scheduler.spawn([Pos.new(0.0)])
	scheduler.physic(0.0)
	return tagged.subscribers == [entity] and scheduler.components.table(Tag)[entity] == true

func test_kill_exits_with_whole_entity_and_uses_does_not_subscribe() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(0.0)])
	var undertaker: Undertaker = Undertaker.new()
	scheduler.open(Undertaker, undertaker, [])
	var bare: int = scheduler.spawn([Pos.new(5.0)])
	var tagged: int = scheduler.spawn([Pos.new(7.0), Tag.new(true)])
	var subscribed: bool = undertaker.subscribers == [tagged]
	scheduler.kill(tagged)
	return subscribed and undertaker.seen == [[tagged, 7.0]] and shift.subscribers == [bare] and scheduler.components.table(Pos)[tagged] == null
