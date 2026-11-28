# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

class Pos:
	extends Reference
	var value: float
	func _init(_value: float) -> void: value = _value

class Way:
	extends Reference
	var value: float
	func _init(_value: float) -> void: value = _value

class Bang:
	extends Reference
	var value: float
	func _init(_value: float) -> void: value = _value

class Shots:
	extends Reference
	var value: int
	func _init(_value: int) -> void: value = _value


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

class Mover:
	extends Functor
	func needs() -> Array: return [Held, Way]
	func update(_delta: float) -> void:
		for subscriber in subscribers:
			if tables[Held][subscriber] & 1: tables[Way][subscriber]+= 1.0

class Fire:
	extends Functor
	func owns() -> Array: return [Shots]
	func update(_delta: float) -> void:
		if tables[Shots][id] == 2: requests.spawning.append([Bang.new(7.0), Transient.new(true), NetId.new(0)])
		tables[Shots][id]+= 1


class Loopback:
	extends Reference
	var host: NetHost
	var guests: Dictionary = {}
	var late: Dictionary = {}
	var sent: int = 0
	var lossy: bool
	func _init(_host: NetHost, _lossy: bool) -> void:
		host = _host
		lossy = _lossy
	func open(peer: int, guest: NetGuest) -> void:
		guests[peer] = guest
		late[peer] = []
		host.joined(peer)
		guest.joined(NetWire.HOST)
	func close(peer: int) -> void:
		guests.erase(peer)
		late.erase(peer)
		host.left(peer)
	func pump() -> void:
		for peer in guests:
			guests[peer].commit()
			for packet in guests[peer].wire[NetWire.OUTBOX]: host.received(peer, packet[NetWire.MESSAGES])
			guests[peer].wire[NetWire.OUTBOX].clear()
			for messages in late[peer]: guests[peer].received(NetWire.HOST, messages)
			late[peer] = []
		for packet in host.wire[NetWire.OUTBOX]:
			for peer in host.targets(packet[NetWire.TARGET]):
				if not guests.has(peer): continue
				sent+= 1
				if packet[NetWire.RELIABLE] or not lossy: guests[peer].received(NetWire.HOST, packet[NetWire.MESSAGES])
				elif sent%3 == 0: continue
				elif sent%3 == 1: late[peer].append(packet[NetWire.MESSAGES])
				else: guests[peer].received(NetWire.HOST, packet[NetWire.MESSAGES])
		host.wire[NetWire.OUTBOX].clear()


const SECRET: String = "test-secret"
const MATCH: String = "m1"

var server: Scheduler
var host: NetHost
var loop: Loopback
var clients: Array = []
var refused: Array = []


func fields() -> NetFields: return NetFields.new([Pos, Bang, Holds, Transient, Way])

func token(player: String, match_id: String, life: int) -> String:
	var payload: String = Marshalls.utf8_to_base64(to_json({"v": 1, "match": match_id, "player": player, "exp": OS.get_unix_time() + life}))
	return payload + "." + HMACTicket.new(SECRET, MATCH).signature(payload)

func open_host(lossy: bool, ticket: NetTicket = NetTicket.new()) -> void:
	server = Scheduler.new()
	clients = []
	refused = []
	var wire: Array = [[], []]
	server.open(Intention, Latch.new(), [])
	server.open(Fire, Fire.new(), [Shots.new(0)])
	server.open(Drift, Drift.new(), [])
	server.open(Mover, Mover.new(), [])
	server.open(Transience, OneTick.new(), [])
	server.open(NetSend, NetSnapshotSend.new(), [NetWire.new(wire), NetIssued.new(1), fields()])
	host = NetHost.new(server, wire, ticket)
	host.connect("refused", self, "on_refused")
	loop = Loopback.new(host, lossy)

func on_refused(peer: int) -> void: refused.append(peer)

func join(pass_token: String = "anyone") -> Dictionary:
	var client: Scheduler = Scheduler.new()
	var wire: Array = [[], []]
	var receive: NetSnapshotReceive = NetSnapshotReceive.new()
	var heard: Heard = Heard.new()
	client.open(NetReceive, receive, [NetWire.new(wire), NetIndex.new({}), fields()])
	client.open(Heard, heard, [])
	var side: Dictionary = {"scheduler": client, "receive": receive, "heard": heard, "guest": NetGuest.new(wire, pass_token), "peer": clients.size() + 2}
	clients.append(side)
	loop.open(side.peer, side.guest)
	return side

func tick(times: int) -> void:
	for i in times:
		server.update(0.1)
		loop.pump()
		for side in clients: side.scheduler.update(0.1)

func net(entity: int) -> int:
	return server.composer.components.tables[NetId][entity]

func replica(side: Dictionary, entity: int) -> int:
	return side.scheduler.composer.components.tables[NetIndex][side.receive.id].get(net(entity), -1)

func value(side: Dictionary, field: GDScript, entity: int):
	return side.scheduler.composer.components.tables[field][replica(side, entity)]

func served(field: GDScript, entity: int):
	return server.composer.components.tables[field][entity]

func ghosts(side: Dictionary) -> int:
	var ids: Array = side.scheduler.composer.components.tables[NetId]
	var alive: int = 0
	for id in side.scheduler.composer.components.count:
		if ids[id] != null: alive+= 1
	return alive - side.receive.subscribers.size()

func pilot(side: Dictionary) -> int:
	return server.composer.spawn([Way.new(0.0), NetId.new(0), Controlled.new(side.peer), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({})])


func test_replica_appears_and_follows() -> bool:
	open_host(false)
	var side: Dictionary = join()
	var body: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(4)
	var lag: float = served(Pos, body) - value(side, Pos, body)
	return net(body) == 1 and replica(side, body) != -1 and lag >= 0.0 and lag <= 2.0

func test_netid_never_reused() -> bool:
	open_host(false)
	join()
	var first: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var first_net: int = net(first)
	server.composer.kill(first)
	var second: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	return second == first and net(second) != first_net

func test_kill_removes_replica() -> bool:
	open_host(false)
	var side: Dictionary = join()
	var body: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(3)
	var copy: int = replica(side, body)
	var body_net: int = net(body)
	server.composer.kill(body)
	tick(2)
	return copy != -1 and not side.scheduler.composer.components.tables[NetIndex][side.receive.id].has(body_net) and side.scheduler.composer.components.free.has(copy)

func test_transient_event_heard_once() -> bool:
	open_host(false)
	var side: Dictionary = join()
	tick(8)
	return side.heard.heard == [7.0]

func test_link_points_to_replica() -> bool:
	open_host(false)
	var side: Dictionary = join()
	var crate: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var grip: int = server.composer.spawn([Holds.new(crate), NetId.new(0)])
	tick(3)
	var holds: Array = side.scheduler.composer.components.tables[Holds]
	var grip_copy: int = replica(side, grip)
	var points: bool = holds[grip_copy] == replica(side, crate)
	server.composer.kill(crate)
	tick(2)
	return points and holds[grip_copy] == null

func test_lossy_state_keeps_replicas_whole() -> bool:
	open_host(true)
	var side: Dictionary = join()
	var bodies: Array = []
	for i in 5: bodies.append(server.composer.spawn([Pos.new(float(i)), NetId.new(0)]))
	tick(10)
	var follows: bool = true
	for body in bodies:
		var lag: float = served(Pos, body) - value(side, Pos, body)
		follows = follows and lag >= 0.0 and lag <= 3.0
	server.composer.kill(bodies[1])
	server.composer.kill(bodies[3])
	tick(10)
	return follows and side.receive.subscribers.size() == 3 and ghosts(side) == 0 and side.heard.heard == [7.0]

func test_late_join_gets_everything() -> bool:
	open_host(true)
	var early: Dictionary = join()
	var crate: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	tick(2)
	var grip: int = server.composer.spawn([Holds.new(crate), NetId.new(0)])
	tick(6)
	var late: Dictionary = join()
	tick(3)
	var holds: Array = late.scheduler.composer.components.tables[Holds]
	return late.receive.subscribers.size() == early.receive.subscribers.size() and holds[replica(late, grip)] == replica(late, crate) and late.heard.heard.empty()

func test_intents_drive_server_from_client() -> bool:
	open_host(true)
	var side: Dictionary = join()
	var other: Dictionary = join()
	var car: int = pilot(side)
	var stranger: int = pilot(other)
	tick(3)
	side.guest.input(0, 0, true)
	tick(5)
	var moving: float = value(side, Way, car)
	side.guest.input(0, 0, false)
	tick(3)
	var stopped: float = served(Way, car)
	tick(3)
	return moving > 0.0 and served(Way, car) == stopped and served(Way, stranger) == 0.0

func test_disconnect_releases_held_intents() -> bool:
	open_host(false)
	var side: Dictionary = join()
	var car: int = pilot(side)
	tick(2)
	side.guest.input(0, 0, true)
	tick(3)
	loop.close(side.peer)
	clients.erase(side)
	tick(2)
	var stopped: float = served(Way, car)
	tick(3)
	return stopped > 0.0 and served(Way, car) == stopped

func test_ticket_admits_valid_and_refuses_others() -> bool:
	open_host(false, HMACTicket.new(SECRET, MATCH))
	var body: int = server.composer.spawn([Pos.new(0.0), NetId.new(0)])
	var good: Dictionary = join(token("p1", MATCH, 60))
	var forged: Dictionary = join(token("p2", MATCH, 60).replace(".", ".x"))
	var stale: Dictionary = join(token("p3", MATCH, -1))
	var foreign: Dictionary = join(token("p4", "m2", 60))
	tick(4)
	var seen: bool = replica(good, body) != -1
	var blind: bool = forged.receive.subscribers.empty() and stale.receive.subscribers.empty() and foreign.receive.subscribers.empty()
	return seen and blind and refused == [forged.peer, stale.peer, foreign.peer] and host.players.size() == 1 and host.players[good.peer] == "p1"

func test_unadmitted_intents_ignored() -> bool:
	open_host(false, HMACTicket.new(SECRET, MATCH))
	var side: Dictionary = join("bad")
	var car: int = pilot(side)
	side.guest.input(0, 0, true)
	tick(4)
	return served(Way, car) == 0.0
