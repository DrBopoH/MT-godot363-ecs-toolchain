# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

enum {APPEAR, STATE, VANISH, JOIN, INPUT}
enum {INBOX, OUTBOX}
enum {TARGET, RELIABLE, MESSAGES}


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

class Way:
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
	var events: Array = []
	func needs() -> Array: return [NetId]
	func owns() -> Array: return [Wire, Counter, Replicates]
	func uses() -> Array: return [Pos, Bang, Holds, Transient, Way]
	func enter(id: int) -> void:
		tables[NetId][id] = tables[Counter][self.id]
		tables[Counter][self.id]+= 1
		events.append(appear(id))
	func exit(id: int) -> void: events.append([VANISH, tables[NetId][id]])
	func appear(subscriber: int) -> Array:
		return [APPEAR, tables[NetId][subscriber], values(subscriber)]
	func values(subscriber: int) -> Array:
		var replicated: Array = tables[Replicates][id]
		var result: Array = []
		for slot in replicated.size():
			var value = tables[replicated[slot]][subscriber]
			if value == null: continue
			if replicated[slot].get_base_script() == Link: value = tables[NetId][value]
			result.append([slot, value])
		return result
	func update(_delta: float) -> void:
		var wire: Array = tables[Wire][id]
		for packet in wire[INBOX]:
			for message in packet:
				if message[0] != JOIN: continue
				var burst: Array = []
				for subscriber in subscribers: burst.append(appear(subscriber))
				wire[OUTBOX].append([message[1], true, burst])
		wire[INBOX].clear()
		if not events.empty(): wire[OUTBOX].append([0, true, events.duplicate()])
		events.clear()
		var state: Array = []
		for subscriber in subscribers: state.append([STATE, tables[NetId][subscriber], values(subscriber)])
		wire[OUTBOX].append([0, false, state])

class Receiver:
	extends Functor
	func needs() -> Array: return [NetId]
	func owns() -> Array: return [Wire, Index, Replicates]
	func uses() -> Array: return [Pos, Bang, Holds, Transient, Way]
	func enter(id: int) -> void: tables[Index][self.id][tables[NetId][id]] = id
	func exit(id: int) -> void: tables[Index][self.id].erase(tables[NetId][id])
	func update(_delta: float) -> void:
		var index: Dictionary = tables[Index][id]
		var replicated: Array = tables[Replicates][id]
		var wire: Array = tables[Wire][id]
		var born: Dictionary = {}
		for packet in wire[INBOX]:
			for message in packet:
				var net: int = message[1]
				match message[0]:
					APPEAR:
						if index.has(net) or born.has(net): continue
						var components: Array = [NetId.new(net)]
						for pair in message[2]:
							var component: GDScript = replicated[pair[0]]
							if component.get_base_script() != Link: components.append(component.new(pair[1]))
							elif index.has(pair[1]): components.append(component.new(index[pair[1]]))
						born[net] = components
					VANISH:
						if born.has(net): born.erase(net)
						elif index.has(net): requests.dying.append(index[net])
					STATE:
						if not index.has(net): continue
						var replica: int = index[net]
						for pair in message[2]:
							var component: GDScript = replicated[pair[0]]
							var value = pair[1]
							if component.get_base_script() == Link:
								if not index.has(value): continue
								value = index[value]
							if tables[component][replica] == null: requests.appearing.append([replica, component.new(value)])
							else: tables[component][replica] = value
		wire[INBOX].clear()
		for net in born: requests.spawning.append(born[net])

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



class Route:
	extends Reference
	var scheduler: Scheduler
	var wire: Array
	var held: Dictionary = {}
	func _init(_scheduler: Scheduler, _wire: Array) -> void:
		scheduler = _scheduler
		wire = _wire
	func joined(peer: int) -> void:
		held[peer] = {}
		wire[INBOX].append([[JOIN, peer]])
	func left(peer: int) -> void:
		for intent in held[peer]: scheduler.input(peer, intent, false)
		held.erase(peer)
	func deliver(peer: int, messages: Array) -> void:
		var rest: Array = []
		for message in messages:
			if message[0] != INPUT:
				rest.append(message)
				continue
			if typeof(message[2]) == TYPE_BOOL:
				if message[2]: held[peer][message[1]] = true
				else: held[peer].erase(message[1])
			scheduler.input(peer, message[1], message[2])
		if not rest.empty(): wire[INBOX].append(rest)

class Uplink:
	extends Reference
	var wire: Array
	var batch: Array = []
	func _init(_wire: Array) -> void: wire = _wire
	func input(_channel: int, intent: int, value) -> void:
		if batch.empty(): wire[OUTBOX].append([1, true, batch])
		batch.append([INPUT, intent, value])
	func sent() -> void: batch = []

class Mover:
	extends Functor
	func needs() -> Array: return [Held, Way]
	func update(_delta: float) -> void:
		for subscriber in subscribers:
			if tables[Held][subscriber] & 1: tables[Way][subscriber]+= 1.0

class Loopback:
	extends Reference
	var route: Route
	var server: Array
	var clients: Dictionary = {}
	var late: Dictionary = {}
	var sent: int = 0
	var lossy: bool
	func _init(_route: Route, _lossy: bool) -> void:
		route = _route
		server = route.wire
		lossy = _lossy
	func connect_peer(peer: int, wire: Array) -> void:
		clients[peer] = wire
		late[peer] = []
		route.joined(peer)
	func disconnect_peer(peer: int) -> void:
		clients.erase(peer)
		late.erase(peer)
		route.left(peer)
	func pump() -> void:
		for peer in clients:
			for packet in clients[peer][OUTBOX]: route.deliver(peer, packet[MESSAGES])
			clients[peer][OUTBOX].clear()
		for peer in clients: clients[peer][INBOX]+= late[peer]
		for peer in late: late[peer] = []
		for packet in server[OUTBOX]:
			for peer in clients:
				if packet[TARGET] != 0 and packet[TARGET] != peer: continue
				sent+= 1
				if packet[RELIABLE] or not lossy: clients[peer][INBOX].append(packet[MESSAGES])
				elif sent%3 == 0: continue
				elif sent%3 == 1: late[peer].append(packet[MESSAGES])
				else: clients[peer][INBOX].append(packet[MESSAGES])
		server[OUTBOX].clear()

class Socket:
	extends Reference
	var peer: NetworkedMultiplayerPeer
	var wire: Array
	var route: Route
	func _init(_peer: NetworkedMultiplayerPeer, _wire: Array, _route: Route) -> void:
		peer = _peer
		wire = _wire
		route = _route
		if route != null:
			peer.connect("peer_connected", route, "joined")
			peer.connect("peer_disconnected", route, "left")
	func pump() -> void:
		peer.poll()
		while peer.get_available_packet_count() > 0:
			var sender: int = peer.get_packet_peer()
			var messages: Array = bytes2var(peer.get_packet())
			if route != null: route.deliver(sender, messages)
			else: wire[INBOX].append(messages)
		for packet in wire[OUTBOX]:
			peer.set_target_peer(packet[TARGET])
			peer.transfer_mode = NetworkedMultiplayerPeer.TRANSFER_MODE_RELIABLE if packet[RELIABLE] else NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
			peer.put_packet(var2bytes(packet[MESSAGES]))
		wire[OUTBOX].clear()



var server: Scheduler
var loop: Loopback
var clients: Array = []


func host(lossy: bool) -> void:
	server = Scheduler.new()
	clients = []
	var wire: Array = [[], []]
	server.open(Intention, Latch.new(), [])
	server.open(Fire, Fire.new(), [Counter.new(0)])
	server.open(Drift, Drift.new(), [])
	server.open(Mover, Mover.new(), [])
	server.open(Transience, OneTick.new(), [])
	server.open(Publisher, Publisher.new(), [Wire.new(wire), Counter.new(1), Replicates.new([Pos, Bang, Holds, Transient, Way])])
	loop = Loopback.new(Route.new(server, wire), lossy)

func join() -> Dictionary:
	var client: Scheduler = Scheduler.new()
	var wire: Array = [[], []]
	var receiver: Receiver = Receiver.new()
	var heard: Heard = Heard.new()
	client.open(Receiver, receiver, [Wire.new(wire), Index.new({}), Replicates.new([Pos, Bang, Holds, Transient, Way])])
	client.open(Heard, heard, [])
	var side: Dictionary = {"scheduler": client, "receiver": receiver, "heard": heard, "uplink": Uplink.new(wire), "peer": clients.size() + 2}
	clients.append(side)
	loop.connect_peer(side.peer, wire)
	return side

func tick(times: int) -> void:
	for i in times:
		server.update(0.1)
		loop.pump()
		for side in clients:
			side.uplink.sent()
			side.scheduler.update(0.1)

func net(entity: int) -> int:
	return server.composer.components.tables[NetId][entity]

func replica(side: Dictionary, entity: int) -> int:
	return side.scheduler.composer.components.tables[Index][side.receiver.id].get(net(entity), -1)

func position(side: Dictionary, entity: int) -> float:
	return side.scheduler.composer.components.tables[Pos][replica(side, entity)]

func ghosts(side: Dictionary) -> int:
	var tables: Array = side.scheduler.composer.components.tables[NetId]
	var alive: int = 0
	for id in side.scheduler.composer.components.count:
		if tables[id] != null: alive+= 1
	return alive - side.receiver.subscribers.size()


func test_replica_appears_and_follows() -> bool:
	host(false)
	var side: Dictionary = join()
	var body: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(4)
	var lag: float = server.composer.components.tables[Pos][body] - position(side, body)
	return net(body) == 1 and replica(side, body) != -1 and lag >= 0.0 and lag <= 2.0

func test_netid_never_reused() -> bool:
	host(false)
	join()
	var first: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var first_net: int = net(first)
	server.composer.kill(first)
	var second: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	return second == first and net(second) != first_net

func test_kill_removes_replica() -> bool:
	host(false)
	var side: Dictionary = join()
	var body: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(3)
	var copy: int = replica(side, body)
	var body_net: int = net(body)
	server.composer.kill(body)
	tick(2)
	return copy != -1 and not side.scheduler.composer.components.tables[Index][side.receiver.id].has(body_net) and side.scheduler.composer.components.free.has(copy)

func test_transient_event_heard_once() -> bool:
	host(false)
	var side: Dictionary = join()
	tick(8)
	return side.heard.heard == [7.0]

func test_link_points_to_replica() -> bool:
	host(false)
	var side: Dictionary = join()
	var crate: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var grip: int = server.composer.spawn([Holds.new(crate), NetId.new(0)])
	tick(3)
	var tables: Dictionary = side.scheduler.composer.components.tables
	var grip_copy: int = replica(side, grip)
	var points: bool = tables[Holds][grip_copy] == replica(side, crate)
	server.composer.kill(crate)
	tick(2)
	return points and tables[Holds][grip_copy] == null

func test_lossy_state_keeps_replicas_whole() -> bool:
	host(true)
	var side: Dictionary = join()
	var bodies: Array = []
	for i in 5: bodies.append(server.composer.spawn([Pos.new(float(i)), NetId.new(0)]))
	tick(10)
	var follows: bool = true
	for body in bodies:
		var lag: float = server.composer.components.tables[Pos][body] - position(side, body)
		follows = follows and lag >= 0.0 and lag <= 3.0
	server.composer.kill(bodies[1])
	server.composer.kill(bodies[3])
	tick(10)
	return follows and side.receiver.subscribers.size() == 3 and ghosts(side) == 0 and side.heard.heard == [7.0]

func test_late_join_gets_everything() -> bool:
	host(true)
	var early: Dictionary = join()
	var crate: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var grip: int = server.composer.spawn([Holds.new(crate), NetId.new(0)])
	tick(6)
	var late: Dictionary = join()
	tick(3)
	var tables: Dictionary = late.scheduler.composer.components.tables
	return late.receiver.subscribers.size() == early.receiver.subscribers.size() and tables[Holds][replica(late, grip)] == replica(late, crate) and late.heard.heard.empty()

func pilot(side: Dictionary) -> int:
	return server.composer.spawn([Way.new(0.0), NetId.new(0), Controlled.new(side.peer), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({})])

func test_intents_drive_server_from_client() -> bool:
	host(true)
	var side: Dictionary = join()
	var other: Dictionary = join()
	var car: int = pilot(side)
	var stranger: int = pilot(other)
	tick(3)
	side.uplink.input(0, 0, true)
	tick(5)
	var moving: float = side.scheduler.composer.components.tables[Way][replica(side, car)]
	side.uplink.input(0, 0, false)
	tick(3)
	var stopped: float = server.composer.components.tables[Way][car]
	tick(3)
	return moving > 0.0 and server.composer.components.tables[Way][car] == stopped and server.composer.components.tables[Way][stranger] == 0.0

func test_disconnect_releases_held_intents() -> bool:
	host(false)
	var side: Dictionary = join()
	var car: int = pilot(side)
	tick(2)
	side.uplink.input(0, 0, true)
	tick(3)
	loop.disconnect_peer(side.peer)
	clients.erase(side)
	tick(2)
	var stopped: float = server.composer.components.tables[Way][car]
	tick(3)
	return stopped > 0.0 and server.composer.components.tables[Way][car] == stopped
