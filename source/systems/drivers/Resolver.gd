# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Resolver
extends Resolution


func update(delta: float) -> void:
	var mask: int = tables[Mask][id]
	var threshold: float = tables[Threshold][id]
	for subscriber in subscribers:
		var held: int = tables[Held][subscriber]
		var released: int = tables[Released][subscriber]
		var durations: Dictionary = tables[Durations][subscriber]
		tables[Clicked][subscriber] = 0
		for intent in 64:
			var bit: int = 1 << intent
			if not mask & bit: continue
			if held & bit:
				durations[intent] = durations.get(intent, 0.0) + delta
				if durations[intent] >= threshold: tables[Holding][subscriber]|= bit
			if released & bit:
				if durations.get(intent, 0.0) < threshold: tables[Clicked][subscriber]|= bit
				durations.erase(intent)
				tables[Holding][subscriber]&= ~bit
