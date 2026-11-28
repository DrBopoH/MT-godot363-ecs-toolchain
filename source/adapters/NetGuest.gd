# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name NetGuest
extends Reference

signal refused(peer)
signal departed(peer)

var wire: Array
var token: String
var batch: Array = []


func _init(_wire: Array, _token: String) -> void:
	wire = _wire
	token = _token


func joined(peer: int) -> void:
	if peer == NetWire.HOST: wire[NetWire.OUTBOX].append([NetWire.HOST, true, [[NetWire.TICKET, token]]])

func left(peer: int) -> void: emit_signal("departed", peer)


func received(_peer: int, messages: Array) -> void: wire[NetWire.INBOX].append(messages)

func input(_channel: int, intent: int, value) -> void: batch.append([NetWire.INPUT, intent, value])

func commit() -> void:
	if batch.empty(): return
	wire[NetWire.OUTBOX].append([NetWire.HOST, true, batch])
	batch = []

func targets(target: int) -> Array: return [target]
