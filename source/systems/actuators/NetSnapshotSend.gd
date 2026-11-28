# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name NetSnapshotSend
extends NetSend

var events: Array = []


func enter(entity: int) -> void:
	tables[NetId][entity] = tables[NetIssued][id]
	tables[NetIssued][id]+= 1
	events.append(appear(entity))

func exit(entity: int) -> void: events.append([NetWire.VANISH, tables[NetId][entity]])


func appear(entity: int) -> Array: return [NetWire.APPEAR, tables[NetId][entity], values(entity)]

func values(entity: int) -> Array:
	var fields: Array = tables[NetFields][id]
	var result: Array = []
	for slot in fields.size():
		var value = tables[fields[slot]][entity]
		if value == null: continue
		if fields[slot].get_base_script() == Link: value = tables[NetId][value]
		result.append([slot, value])
	return result


func update(_delta: float) -> void:
	var wire: Array = tables[NetWire][id]
	for packet in wire[NetWire.INBOX]:
		for message in packet:
			if message[0] != NetWire.JOIN: continue
			var burst: Array = []
			for subscriber in subscribers: burst.append(appear(subscriber))
			wire[NetWire.OUTBOX].append([message[1], true, burst])
	wire[NetWire.INBOX].clear()
	if not events.empty(): wire[NetWire.OUTBOX].append([NetWire.EVERYONE, true, events.duplicate()])
	events.clear()
	var state: Array = []
	for subscriber in subscribers: state.append([NetWire.STATE, tables[NetId][subscriber], values(subscriber)])
	wire[NetWire.OUTBOX].append([NetWire.EVERYONE, false, state])
