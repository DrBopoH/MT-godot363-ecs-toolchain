# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

const RIGHT: int = 3
const LEFT: int = 2
const UP: int = 7
const DOWN: int = 8
const FORWARD: int = 0
const BACK: int = 1


func rig() -> Array:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.open(Intention, Latch.new(), [])
	scheduler.open(Conversion, DirectionFromIntents.new(), [Directions.new([RIGHT, LEFT, UP, DOWN, FORWARD, BACK])])
	var pilot: int = scheduler.composer.spawn([
		Controlled.new(0), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({}), Direction.new(Vector3.ZERO)
	])
	return [scheduler, pilot]

func direction(rig: Array) -> Vector3: return rig[0].composer.components.tables[Direction][rig[1]]




func test_held_intents_become_a_direction() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FORWARD, true)
	scheduler.input(0, RIGHT, true)
	scheduler.physic(0.1)
	var both: Vector3 = direction(rig)
	scheduler.input(0, RIGHT, false)
	scheduler.input(0, UP, true)
	scheduler.physic(0.1)
	return both == Vector3(1, 0, -1) and direction(rig) == Vector3(0, 1, -1)

func test_opposite_intents_cancel() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, LEFT, true)
	scheduler.input(0, RIGHT, true)
	scheduler.input(0, BACK, true)
	scheduler.physic(0.1)
	return direction(rig) == Vector3(0, 0, 1)

func test_direction_cannot_stick_after_release() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FORWARD, true)
	scheduler.physic(0.1)
	scheduler.input(0, FORWARD, false)
	scheduler.input(0, FORWARD, false)
	scheduler.physic(0.1)
	return direction(rig) == Vector3.ZERO
