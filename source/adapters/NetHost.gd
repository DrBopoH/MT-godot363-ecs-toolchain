# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name NetHost
extends Reference

signal admitted(peer, player)
signal refused(peer)
signal departed(peer)

var sink: Object
var wire: Array
var ticket: NetTicket
var players: Dictionary = {}
var held: Dictionary = {}


func _init(_sink: Object, _wire: Array, _ticket: NetTicket) -> void:
	sink = _sink
	wire = _wire
	ticket = _ticket


func joined(_peer: int) -> void: return

func left(peer: int) -> void:
	if not players.has(peer): return
	for intent in held[peer]: sink.input(peer, intent, false)
	held.erase(peer)
	players.erase(peer)
	emit_signal("departed", peer)


func received(peer: int, messages: Array) -> void:
	if not players.has(peer):
		admit(peer, messages)
		return
	var rest: Array = []
	for message in messages:
		if message[0] != NetWire.INPUT:
			rest.append(message)
			continue
		if typeof(message[2]) == TYPE_BOOL:
			if message[2]: held[peer][message[1]] = true
			else: held[peer].erase(message[1])
		sink.input(peer, message[1], message[2])
	if not rest.empty(): wire[NetWire.INBOX].append(rest)

func admit(peer: int, messages: Array) -> void:
	var player: String = ticket.verify(messages[0][1]) if messages[0][0] == NetWire.TICKET else ""
	if player.empty():
		emit_signal("refused", peer)
		return
	players[peer] = player
	held[peer] = {}
	wire[NetWire.INBOX].append([[NetWire.JOIN, peer]])
	emit_signal("admitted", peer, player)


func commit() -> void: return

func targets(target: int) -> Array: return players.keys() if target == NetWire.EVERYONE else [target]
