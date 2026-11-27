# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

const FIRE: int = 2
const FORWARD: int = 6
const LOOK: int = 1


func rig() -> Array:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.open(Intention, Latch.new(), [])
	var pilot: int = scheduler.composer.spawn([Controlled.new(0), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({})])
	var other: int = scheduler.composer.spawn([Controlled.new(1), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({})])
	return [scheduler, pilot, other]

func state(scheduler: Scheduler, id: int) -> Array:
	var tables: Dictionary = scheduler.composer.components.tables
	return [tables[Held][id], tables[Pressed][id], tables[Released][id]]




func test_press_and_hold_reach_only_their_channel() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FORWARD, true)
	scheduler.update(0.0)
	var first: Array = state(scheduler, rig[1])
	scheduler.update(0.0)
	var second: Array = state(scheduler, rig[1])
	var bit: int = 1 << FORWARD
	return first == [bit, bit, 0] and second == [bit, 0, 0] and state(scheduler, rig[2]) == [0, 0, 0]

func test_release_in_the_same_tick_is_deferred() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FIRE, true)
	scheduler.input(0, FIRE, false)
	scheduler.update(0.0)
	var first: Array = state(scheduler, rig[1])
	scheduler.update(0.0)
	var second: Array = state(scheduler, rig[1])
	scheduler.update(0.0)
	var bit: int = 1 << FIRE
	return first == [bit, bit, 0] and second == [0, 0, bit] and state(scheduler, rig[1]) == [0, 0, 0]

func test_axes_sum_within_a_tick_and_reset() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, LOOK, Vector2(1, 0))
	scheduler.input(0, LOOK, Vector2(2, -1))
	scheduler.update(0.0)
	var first: Vector2 = scheduler.composer.components.tables[Axes][rig[1]][LOOK]
	scheduler.update(0.0)
	return first == Vector2(3, -1) and scheduler.composer.components.tables[Axes][rig[1]].empty()

func test_repeated_press_keeps_one_edge() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FORWARD, true)
	scheduler.update(0.0)
	scheduler.input(0, FORWARD, true)
	scheduler.update(0.0)
	return state(scheduler, rig[1]) == [1 << FORWARD, 0, 0]
