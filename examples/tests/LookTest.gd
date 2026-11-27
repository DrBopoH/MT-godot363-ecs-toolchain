# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

const LOOK: int = 6


func test_mouse_turns_and_pitch_is_clamped() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.open(Intention, Latch.new(), [])
	scheduler.open(Looking, RelativeEuler.new(), [Trigger.new(LOOK), Sensitivity.new(0.01), PitchLimits.new(Vector2(-45, 45))])
	var eye: int = scheduler.composer.spawn([Controlled.new(0), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({}), Orientation.new(Vector3.ZERO)])
	scheduler.input(0, LOOK, Vector2(100, 0))
	scheduler.physic(0.1)
	var turned: Vector3 = scheduler.composer.components.tables[Orientation][eye]
	scheduler.input(0, LOOK, Vector2(0, -1000))
	scheduler.physic(0.1)
	var pitched: Vector3 = scheduler.composer.components.tables[Orientation][eye]
	return is_equal_approx(turned.y, -1.0) and turned.x == 0.0 and is_equal_approx(pitched.x, deg2rad(45))

func test_local_thrust_follows_the_view_without_pure_vertical() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.open(Thrust, LocalThrust.new(), [])
	var right_turn: int = scheduler.composer.spawn([Direction.new(Vector3(0, 0, -1)), Speed.new(2.0), Velocity.new(Vector3.ZERO), Orientation.new(Vector3(0, -PI/2, 0))])
	var climb: int = scheduler.composer.spawn([Direction.new(Vector3(0, 1, 0)), Speed.new(2.0), Velocity.new(Vector3.ZERO), Orientation.new(Vector3.ZERO)])
	var dive: int = scheduler.composer.spawn([Direction.new(Vector3(0, 0, -1)), Speed.new(2.0), Velocity.new(Vector3.ZERO), Orientation.new(Vector3(-PI/4, 0, 0))])
	scheduler.physic(0.1)
	var velocities: Array = scheduler.composer.components.tables[Velocity]
	return velocities[right_turn].is_equal_approx(Vector3(2, 0, 0)) and velocities[climb] == Vector3.ZERO and velocities[dive].y < 0.0
