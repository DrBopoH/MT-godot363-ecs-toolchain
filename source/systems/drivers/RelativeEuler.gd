# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name RelativeEuler
extends Looking


func update(_delta: float) -> void:
	var look: int = tables[Trigger][id]
	var sensitivity: float = tables[Sensitivity][id]
	var limits: Vector2 = tables[PitchLimits][id]
	for subscriber in subscribers:
		var motion: Vector2 = tables[Axes][subscriber].get(look, Vector2.ZERO)
		var orientation: Vector3 = tables[Orientation][subscriber]
		orientation.y-= motion.x*sensitivity
		orientation.x = clamp(orientation.x - motion.y*sensitivity, deg2rad(limits.x), deg2rad(limits.y))
		tables[Orientation][subscriber] = orientation
