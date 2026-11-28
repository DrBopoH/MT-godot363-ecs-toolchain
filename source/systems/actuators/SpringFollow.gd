# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name SpringFollow
extends Springing


func update(_delta: float) -> void:
	var strength: float = tables[Strength][id]
	for subscriber in subscribers:
		var body: RigidBody = tables[Proxy][tables[Holds][subscriber]]
		var contact: Vector3 = body.global_transform.xform(tables[Grip][subscriber])
		var arm: Vector3 = contact - body.global_transform.origin
		var k: float = body.mass*strength
		var c: float = 2.0*sqrt(body.mass*k)
		var velocity: Vector3 = body.linear_velocity + body.angular_velocity.cross(arm)
		body.add_force((tables[Position][subscriber] - contact)*k - velocity*c, arm)
