# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Latch
extends Intention


func update(_delta: float) -> void:
	var held: Array = tables[Held]
	var pressed: Array = tables[Pressed]
	var released: Array = tables[Released]
	var axes: Array = tables[Axes]
	for subscriber in subscribers:
		pressed[subscriber] = 0
		released[subscriber] = 0
		axes[subscriber].clear()
	var batch: Array = requests.inputs.duplicate()
	requests.inputs.clear()
	for entry in batch:
		var bit: int = 1 << entry[1]
		for subscriber in subscribers:
			if tables[Controlled][subscriber] != entry[0]: continue
			if typeof(entry[2]) != TYPE_BOOL:
				axes[subscriber][entry[1]] = axes[subscriber].get(entry[1], entry[2]*0) + entry[2]
			elif entry[2]:
				pressed[subscriber]|= bit & ~held[subscriber]
				held[subscriber]|= bit
			elif pressed[subscriber] & bit:
				requests.inputs.append(entry)
			else:
				held[subscriber]&= ~bit
				released[subscriber]|= bit
