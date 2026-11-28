# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name RaycastPicker
extends Picking


func update(_delta: float) -> void:
	var bit: int = 1 << tables[Trigger][id]
	var proxies: Array = tables[Proxy]
	for subscriber in subscribers:
		if tables[Pressed][subscriber] & bit: pick(subscriber, proxies)
		if tables[Released][subscriber] & bit: drop(subscriber)

func pick(holder: int, proxies: Array) -> void:
	var camera: Camera = proxies[holder]
	var cursor: Vector2 = camera.get_viewport().get_mouse_position()
	var origin: Vector3 = camera.project_ray_origin(cursor)
	var hit: Dictionary = camera.get_world().direct_space_state.intersect_ray(origin, origin + camera.project_ray_normal(cursor)*camera.far)
	if hit.empty() or not hit.collider is RigidBody: return
	var body: int = proxies.find(hit.collider)
	if body == -1: return
	requests.spawning.append([
		Holder.new(holder),
		Holds.new(body),
		Grip.new(hit.collider.global_transform.xform_inv(hit.position)),
		Reach.new(origin.distance_to(hit.position)),
		Position.new(hit.position)
	])

func drop(holder: int) -> void:
	var holders: Array = tables[Holder]
	for grip in holders.size():
		if holders[grip] == holder: requests.dying.append(grip)
