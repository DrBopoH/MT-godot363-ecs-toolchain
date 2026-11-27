# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

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

class Aim:
	extends Link
	var value: int
	func _init(_value: int) -> void: value = _value

class Chase:
	extends Functor
	var released: Array = []
	func needs() -> Array: return [Pos, Aim]
	func rate() -> int: return PHYSIC
	func exit(id: int) -> void: released.append([id, tables[Pos][tables[Aim][id]]])

class Bang:
	extends Event
	var value: float
	func _init(_value: float) -> void: value = _value

class Hearer:
	extends Functor
	var heard: Array = []
	func needs() -> Array: return [Bang]
	func rate() -> int: return PHYSIC
	func update(_delta: float) -> void:
		for subscriber in subscribers: heard.append(tables[Bang][subscriber])

class Shooter:
	extends Functor
	func owns() -> Array: return [Pos]
	func rate() -> int: return PHYSIC
	func update(_delta: float) -> void:
		if tables[Pos][id] == 0.0: requests.spawning.append([Bang.new(7.0)])
		tables[Pos][id]+= 1.0

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
			if tables[Pos][subscriber] >= 4.0: requests.dying.append(subscriber)

class Undertaker:
	extends Functor
	var seen: Array = []
	func needs() -> Array: return [Tag]
	func uses() -> Array: return [Pos]
	func rate() -> int: return RENDER
	func exit(id: int) -> void: seen.append([id, tables[Pos][id]])

class Emitter:
	extends Functor
	var exits: int = 0
	func exit(_id: int) -> void: exits+= 1
	func owns() -> Array: return [Pos]
	func rate() -> int: return PHYSIC
	func update(_delta: float) -> void: requests.spawning.append([Pos.new(tables[Pos][id]), Tag.new(true)])

class Tagger:
	extends Functor
	func needs() -> Array: return [Pos]
	func rate() -> int: return PHYSIC
	func update(_delta: float) -> void:
		for subscriber in subscribers:
			if tables[Pos][subscriber] >= 2.0: requests.appearing.append([subscriber, Tag.new(true)])

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
	var moving: int = scheduler.composer.spawn([Pos.new(0.0)])
	var still: int = scheduler.composer.spawn([Tag.new(true)])
	scheduler.physic(0.0)
	return shift.subscribers == [moving] and scheduler.composer.components.table(Pos)[moving] == 2.0 and scheduler.composer.components.table(Tag)[still] == true

func test_open_subscribes_existing() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var early: int = scheduler.composer.spawn([Pos.new(0.0)])
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(2.0)])
	var late: int = scheduler.composer.spawn([Pos.new(10.0)])
	return shift.subscribers == [early, late]

func test_add_and_remove_resubscribe() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var tagged: Tagged = Tagged.new()
	scheduler.open(Tagged, tagged, [])
	var entity: int = scheduler.composer.spawn([Pos.new(0.0)])
	var before: bool = tagged.subscribers.empty()
	scheduler.composer.add(entity, Tag.new(true))
	var added: bool = tagged.subscribers == [entity]
	scheduler.composer.remove(entity, Tag)
	return before and added and tagged.subscribers.empty() and scheduler.composer.components.table(Tag)[entity] == null

func test_swap_keeps_id_params_and_subscribers() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(2.0)])
	var entity: int = scheduler.composer.spawn([Pos.new(0.0)])
	scheduler.physic(0.0)
	var reverse: ReverseShift = ReverseShift.new()
	scheduler.swap(Shift, reverse)
	scheduler.physic(0.0)
	scheduler.physic(0.0)
	return reverse.id == shift.id and reverse.subscribers == [entity] and scheduler.composer.components.table(Pos)[entity] == -2.0

func test_dying_kills_after_tick() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(2.0)])
	scheduler.open(Reaper, Reaper.new(), [])
	var doomed: int = scheduler.composer.spawn([Pos.new(2.0), Tag.new(true)])
	var safe: int = scheduler.composer.spawn([Pos.new(-10.0)])
	scheduler.physic(0.0)
	scheduler.physic(0.0)
	return shift.subscribers == [safe] and scheduler.composer.components.table(Pos)[doomed] == null and scheduler.composer.components.table(Tag)[doomed] == null

func test_enter_and_exit_see_data() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var witness: Witness = Witness.new()
	scheduler.open(Witness, witness, [])
	var entity: int = scheduler.composer.spawn([Pos.new(3.0)])
	scheduler.composer.remove(entity, Pos)
	return witness.seen == [["enter", entity, 3.0], ["exit", entity, 3.0]]

func test_appearing_adds_after_tick_before_dying() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var tagged: Tagged = Tagged.new()
	scheduler.open(Shift, Shift.new(), [Grav.new(2.0)])
	scheduler.open(Tagger, Tagger.new(), [])
	scheduler.open(Tagged, tagged, [])
	var entity: int = scheduler.composer.spawn([Pos.new(0.0)])
	scheduler.physic(0.0)
	return tagged.subscribers == [entity] and scheduler.composer.components.table(Tag)[entity] == true

func test_kill_exits_with_whole_entity_and_uses_does_not_subscribe() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(0.0)])
	var undertaker: Undertaker = Undertaker.new()
	scheduler.open(Undertaker, undertaker, [])
	var bare: int = scheduler.composer.spawn([Pos.new(5.0)])
	var tagged: int = scheduler.composer.spawn([Pos.new(7.0), Tag.new(true)])
	var subscribed: bool = undertaker.subscribers == [tagged]
	scheduler.composer.kill(tagged)
	return subscribed and undertaker.seen == [[tagged, 7.0]] and shift.subscribers == [bare] and scheduler.composer.components.table(Pos)[tagged] == null

func test_spawning_creates_entities_after_tick() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var tagged: Tagged = Tagged.new()
	scheduler.open(Tagged, tagged, [])
	scheduler.open(Emitter, Emitter.new(), [Pos.new(9.0)])
	var before: int = scheduler.composer.components.count
	scheduler.physic(0.0)
	var born: int = scheduler.composer.components.count - 1
	return scheduler.composer.components.count == before + 1 and tagged.subscribers == [born] and scheduler.composer.components.table(Pos)[born] == 9.0

func test_killed_ids_are_reused_clean() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var tagged: Tagged = Tagged.new()
	scheduler.open(Tagged, tagged, [])
	var first: int = scheduler.composer.spawn([Pos.new(1.0), Tag.new(true)])
	scheduler.composer.kill(first)
	var second: int = scheduler.composer.spawn([Pos.new(2.0)])
	return second == first and tagged.subscribers.empty() and scheduler.composer.components.table(Tag)[second] == null and scheduler.composer.components.table(Pos)[second] == 2.0

func test_open_without_needs_subscribes_nobody() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.composer.spawn([Pos.new(1.0)])
	var emitter: Emitter = Emitter.new()
	scheduler.open(Emitter, emitter, [Pos.new(0.0)])
	var other: int = scheduler.composer.spawn([Pos.new(2.0)])
	scheduler.composer.kill(other)
	return emitter.subscribers.empty() and emitter.exits == 0

func test_killing_a_target_cuts_links_to_it_first() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var chase: Chase = Chase.new()
	scheduler.open(Chase, chase, [])
	var anchor: int = scheduler.composer.spawn([Pos.new(4.0)])
	var body: int = scheduler.composer.spawn([Pos.new(0.0), Aim.new(anchor)])
	var bystander: int = scheduler.composer.spawn([Pos.new(1.0)])
	var linked: bool = chase.subscribers == [body]
	scheduler.composer.kill(anchor)
	var reborn: int = scheduler.composer.spawn([Pos.new(9.0)])
	return linked and chase.released == [[body, 4.0]] and chase.subscribers.empty() and scheduler.composer.components.table(Aim)[body] == null and scheduler.composer.components.table(Pos)[body] == 0.0 and reborn == anchor

func test_tables_double_when_ids_run_out() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.composer.components.capacity = 2
	var shift: Shift = Shift.new()
	scheduler.open(Shift, shift, [Grav.new(1.0)])
	var first: int = scheduler.composer.spawn([Pos.new(0.0)])
	var second: int = scheduler.composer.spawn([Pos.new(10.0)])
	scheduler.physic(0.0)
	return scheduler.composer.components.capacity == 4 and shift.subscribers == [first, second] and scheduler.composer.components.table(Pos)[second] == 11.0 and shift.tables[Pos].size() == 4

func test_events_live_exactly_one_tick() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var hearer: Hearer = Hearer.new()
	scheduler.open(Shooter, Shooter.new(), [Pos.new(0.0)])
	scheduler.open(Hearer, hearer, [])
	scheduler.physic(0.0)
	var born: bool = hearer.subscribers.size() == 1 and hearer.heard.empty()
	scheduler.physic(0.0)
	var heard_once: bool = hearer.heard == [7.0] and hearer.subscribers.empty()
	scheduler.physic(0.0)
	return born and heard_once and hearer.heard == [7.0]

func test_double_death_frees_the_id_once() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	var entity: int = scheduler.composer.spawn([Pos.new(0.0)])
	scheduler.composer.requests.dying.append(entity)
	scheduler.composer.requests.dying.append(entity)
	scheduler.physic(0.0)
	var first: int = scheduler.composer.spawn([Pos.new(1.0)])
	var second: int = scheduler.composer.spawn([Pos.new(2.0)])
	return first == entity and second != entity
