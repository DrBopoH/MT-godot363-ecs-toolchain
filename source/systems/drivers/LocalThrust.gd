# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name LocalThrust
extends Thrust


func update(_delta: float) -> void:
	for subscriber in subscribers:
		var basis: Basis = Basis(tables[Orientation][subscriber])
		var direction: Vector3 = tables[Direction][subscriber]
		var heading: Vector3 = basis.x*direction.x + basis.z*direction.z
		tables[Velocity][subscriber] = heading.normalized()*tables[Speed][subscriber]
