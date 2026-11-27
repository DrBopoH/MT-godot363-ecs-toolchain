# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

const FIRE: int = 4
const LOOK: int = 6
const STEP: float = 0.1


func rig() -> Array:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.open(Intention, Latch.new(), [])
	scheduler.open(Resolution, Resolver.new(), [Mask.new(1 << FIRE), Threshold.new(0.25)])
	var pilot: int = scheduler.composer.spawn([
		Controlled.new(0), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({}),
		Durations.new({}), Clicked.new(0), Holding.new(0)
	])
	return [scheduler, pilot]

func read(scheduler: Scheduler, id: int) -> Array:
	var tables: Dictionary = scheduler.composer.components.tables
	return [tables[Clicked][id], tables[Holding][id]]




func test_tap_is_a_click() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FIRE, true)
	scheduler.update(STEP)
	var down: Array = read(scheduler, rig[1])
	scheduler.input(0, FIRE, false)
	scheduler.update(STEP)
	var up: Array = read(scheduler, rig[1])
	scheduler.update(STEP)
	return down == [0, 0] and up == [1 << FIRE, 0] and read(scheduler, rig[1]) == [0, 0]

func test_long_press_is_a_hold_not_a_click() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FIRE, true)
	var trace: Array = []
	for i in 4:
		scheduler.update(STEP)
		trace.append(read(scheduler, rig[1])[1])
	scheduler.input(0, FIRE, false)
	scheduler.update(STEP)
	var bit: int = 1 << FIRE
	return trace == [0, 0, bit, bit] and read(scheduler, rig[1]) == [0, 0]

func test_tap_in_one_tick_is_a_click_next_tick() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, FIRE, true)
	scheduler.input(0, FIRE, false)
	scheduler.update(STEP)
	var first: Array = read(scheduler, rig[1])
	scheduler.update(STEP)
	return first == [0, 0] and read(scheduler, rig[1]) == [1 << FIRE, 0]

func test_intents_outside_the_mask_are_not_resolved() -> bool:
	var rig: Array = rig()
	var scheduler: Scheduler = rig[0]
	scheduler.input(0, 2, true)
	scheduler.update(STEP)
	scheduler.input(0, 2, false)
	scheduler.update(STEP)
	return read(scheduler, rig[1]) == [0, 0]
