# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference




func test_direction_becomes_velocity_without_diagonal_boost() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.open(Thrust, DirectThrust.new(), [])
	var straight: int = scheduler.composer.spawn([Direction.new(Vector3(0, 0, -1)), Speed.new(3.0), Velocity.new(Vector3.ZERO)])
	var diagonal: int = scheduler.composer.spawn([Direction.new(Vector3(1, 1, -1)), Speed.new(3.0), Velocity.new(Vector3.ZERO)])
	var idle: int = scheduler.composer.spawn([Direction.new(Vector3.ZERO), Speed.new(3.0), Velocity.new(Vector3(5, 0, 0))])
	scheduler.update(0.1)
	var velocities: Array = scheduler.composer.components.tables[Velocity]
	return velocities[straight] == Vector3(0, 0, -3) and abs(velocities[diagonal].length() - 3.0) < 0.0001 and velocities[diagonal].y > 0.0 and velocities[idle] == Vector3.ZERO
