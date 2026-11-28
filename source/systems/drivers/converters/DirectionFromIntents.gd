# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name DirectionFromIntents
extends Conversion


func update(_delta: float) -> void:
	var intents: Array = tables[Directions][id]
	for subscriber in subscribers:
		var held: int = tables[Held][subscriber]
		tables[Direction][subscriber] = Vector3(
			axis(held, intents[0], intents[1]),
			axis(held, intents[2], intents[3]),
			axis(held, intents[5], intents[4])
		)

func axis(held: int, positive: int, negative: int) -> float:
	return float(int(held & (1 << positive) != 0) - int(held & (1 << negative) != 0))
