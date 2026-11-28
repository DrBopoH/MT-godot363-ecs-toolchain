# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name NetSnapshotReceive
extends NetReceive


func enter(entity: int) -> void: tables[NetIndex][id][tables[NetId][entity]] = entity

func exit(entity: int) -> void: tables[NetIndex][id].erase(tables[NetId][entity])


func update(_delta: float) -> void:
	var index: Dictionary = tables[NetIndex][id]
	var fields: Array = tables[NetFields][id]
	var wire: Array = tables[NetWire][id]
	var born: Dictionary = {}
	for packet in wire[NetWire.INBOX]:
		for message in packet:
			var net: int = message[1]
			match message[0]:
				NetWire.APPEAR:
					if index.has(net) or born.has(net): continue
					var components: Array = [NetId.new(net)]
					for pair in message[2]:
						var field: GDScript = fields[pair[0]]
						if field.get_base_script() != Link: components.append(field.new(pair[1]))
						elif index.has(pair[1]): components.append(field.new(index[pair[1]]))
					born[net] = components
				NetWire.VANISH:
					if born.has(net): born.erase(net)
					elif index.has(net): requests.dying.append(index[net])
				NetWire.STATE:
					if not index.has(net): continue
					var replica: int = index[net]
					for pair in message[2]:
						var field: GDScript = fields[pair[0]]
						var value = pair[1]
						if field.get_base_script() == Link:
							if not index.has(value): continue
							value = index[value]
						if tables[field][replica] == null: requests.appearing.append([replica, field.new(value)])
						else: tables[field][replica] = value
	wire[NetWire.INBOX].clear()
	for net in born: requests.spawning.append(born[net])
