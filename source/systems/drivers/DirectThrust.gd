# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name DirectThrust
extends Thrust


func update(_delta: float) -> void:
	var directions: Array = tables[Direction]
	var speeds: Array = tables[Speed]
	var velocities: Array = tables[Velocity]
	for subscriber in subscribers: velocities[subscriber] = directions[subscriber].normalized()*speeds[subscriber]
