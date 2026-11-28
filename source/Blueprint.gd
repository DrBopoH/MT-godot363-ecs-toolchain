# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Blueprint
extends Resource

var carriers: Array = []
var cursor: int = 0


func _iter_init(_state) -> bool:
	cursor = 0
	return cursor < carriers.size()

func _iter_next(_state) -> bool:
	cursor+= 1
	return cursor < carriers.size()

func _iter_get(_state):
	var carrier = carriers[cursor]
	if typeof(carrier.value) in [TYPE_ARRAY, TYPE_DICTIONARY]: return carrier.get_script().new(carrier.value.duplicate(true))
	return carrier
