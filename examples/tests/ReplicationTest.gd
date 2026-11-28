# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

enum {APPEAR, STATE, VANISH}


class NetId:
	extends Reference
	var value: int
	func _init(_value: int) -> void: value = _value

class Pos:
	extends Reference
	var value: float
	func _init(_value: float) -> void: value = _value

class Bang:
	extends Reference
	var value: float
	func _init(_value: float) -> void: value = _value

class Wire:
	extends Reference
	var value: Array
	func _init(_value: Array) -> void: value = _value

class Counter:
	extends Reference
	var value: int
	func _init(_value: int) -> void: value = _value

class Index:
	extends Reference
	var value: Dictionary
	func _init(_value: Dictionary) -> void: value = _value


class Replicates:
	extends Reference
	var value: Array
	func _init(_value: Array) -> void: value = _value



class Publisher:
	extends Functor
	var outbox: Array = []
	func needs() -> Array: return [NetId]
	func owns() -> Array: return [Wire, Counter, Replicates]
	func uses() -> Array: return [Pos, Bang, Holds, Transient]
	func enter(id: int) -> void:
		tables[NetId][id] = tables[Counter][self.id]
		tables[Counter][self.id]+= 1
		outbox.append([APPEAR, tables[NetId][id]])
	func exit(id: int) -> void: outbox.append([VANISH, tables[NetId][id]])
	func update(_delta: float) -> void:
		var replicated: Array = tables[Replicates][id]
		var packet: Array = []
		for message in outbox:
			if message[0] == APPEAR: packet.append(message)
		for subscriber in subscribers:
			for slot in replicated.size():
				var value = tables[replicated[slot]][subscriber]
				if value == null: continue
				if replicated[slot].get_base_script() == Link: value = tables[NetId][value]
				packet.append([STATE, tables[NetId][subscriber], slot, value])
		for message in outbox:
			if message[0] == VANISH: packet.append(message)
		outbox.clear()
		tables[Wire][id].append(packet)

class Receiver:
	extends Functor
	func needs() -> Array: return [NetId]
	func owns() -> Array: return [Wire, Index, Replicates]
	func uses() -> Array: return [Pos, Bang, Holds, Transient]
	func enter(id: int) -> void: tables[Index][self.id][tables[NetId][id]] = id
	func exit(id: int) -> void: tables[Index][self.id].erase(tables[NetId][id])
	func update(_delta: float) -> void:
		var index: Dictionary = tables[Index][id]
		var replicated: Array = tables[Replicates][id]
		for packet in tables[Wire][id]:
			var born: Dictionary = {}
			for message in packet:
				var net: int = message[1]
				match message[0]:
					APPEAR: born[net] = [NetId.new(net)]
					VANISH: requests.dying.append(index[net])
					STATE:
						var component: GDScript = replicated[message[2]]
						var value = message[3]
						if component.get_base_script() == Link:
							if not index.has(value): continue
							value = index[value]
						if born.has(net):
							born[net].append(component.new(value))
						elif tables[component][index[net]] == null:
							requests.appearing.append([index[net], component.new(value)])
						else:
							tables[component][index[net]] = value
			for net in born: requests.spawning.append(born[net])
		tables[Wire][id].clear()

class Heard:
	extends Functor
	var heard: Array = []
	func needs() -> Array: return [Bang]
	func update(_delta: float) -> void:
		for subscriber in subscribers: heard.append(tables[Bang][subscriber])

class Drift:
	extends Functor
	func needs() -> Array: return [Pos]
	func update(_delta: float) -> void:
		for subscriber in subscribers: tables[Pos][subscriber]+= 1.0

class Fire:
	extends Functor
	func owns() -> Array: return [Counter]
	func update(_delta: float) -> void:
		if tables[Counter][id] == 2: requests.spawning.append([Bang.new(7.0), Transient.new(true), NetId.new(0)])
		tables[Counter][id]+= 1



var server: Scheduler
var client: Scheduler
var receiver: Receiver
var heard: Heard


func link() -> void:
	server = Scheduler.new()
	client = Scheduler.new()
	var wire: Array = []
	server.open(Fire, Fire.new(), [Counter.new(0)])
	server.open(Drift, Drift.new(), [])
	server.open(Transience, OneTick.new(), [])
	var replicated: Array = [Pos, Bang, Holds, Transient]
	server.open(Publisher, Publisher.new(), [Wire.new(wire), Counter.new(1), Replicates.new(replicated)])
	receiver = Receiver.new()
	heard = Heard.new()
	client.open(Receiver, receiver, [Wire.new(wire), Index.new({}), Replicates.new(replicated)])
	client.open(Heard, heard, [])

func tick(times: int) -> void:
	for i in times:
		server.update(0.1)
		client.update(0.1)

func replica(net: int) -> int:
	return client.composer.components.tables[Index][receiver.id].get(net, -1)

func position(net: int) -> float:
	return client.composer.components.tables[Pos][replica(net)]


func test_replica_appears_and_follows() -> bool:
	link()
	var body: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(4)
	var net: int = server.composer.components.tables[NetId][body]
	var lag: float = server.composer.components.tables[Pos][body] - position(net)
	return net == 1 and replica(net) != -1 and lag >= 0.0 and lag <= 2.0

func test_netid_never_reused() -> bool:
	link()
	var first: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var first_net: int = server.composer.components.tables[NetId][first]
	server.composer.kill(first)
	var second: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	return second == first and server.composer.components.tables[NetId][second] != first_net

func test_kill_removes_replica() -> bool:
	link()
	var body: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(3)
	var net: int = server.composer.components.tables[NetId][body]
	var copy: int = replica(net)
	server.composer.kill(body)
	tick(2)
	return copy != -1 and replica(net) == -1 and client.composer.components.free.has(copy)

func test_transient_event_heard_once() -> bool:
	link()
	tick(8)
	return heard.heard == [7.0]

func test_link_points_to_replica() -> bool:
	link()
	var crate: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var grip: int = server.composer.spawn([Holds.new(crate), NetId.new(0)])
	tick(3)
	var tables: Dictionary = client.composer.components.tables
	var crate_net: int = server.composer.components.tables[NetId][crate]
	var grip_net: int = server.composer.components.tables[NetId][grip]
	var points: bool = tables[Holds][replica(grip_net)] == replica(crate_net)
	server.composer.kill(crate)
	tick(2)
	return points and tables[Holds][replica(grip_net)] == null
