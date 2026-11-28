# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name LinearMovement
extends Movement


func update(delta: float) -> void:
	var positions: Array = tables[Position]
	var velocities: Array = tables[Velocity]
	for subscriber in subscribers: positions[subscriber]+= velocities[subscriber]*delta
