# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name AnchorFollow
extends Following


func update(_delta: float) -> void:
	var positions: Array = tables[Position]
	var targets: Array = tables[Target]
	var offsets: Array = tables[Offset]
	for subscriber in subscribers: positions[subscriber] = positions[targets[subscriber]] + offsets[subscriber]
