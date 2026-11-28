# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name CursorAnchor
extends Pointing


func update(_delta: float) -> void:
	for subscriber in subscribers:
		var camera: Camera = tables[Proxy][tables[Holder][subscriber]]
		var cursor: Vector2 = camera.get_viewport().get_mouse_position()
		tables[Position][subscriber] = camera.project_ray_origin(cursor) + camera.project_ray_normal(cursor)*tables[Reach][subscriber]
