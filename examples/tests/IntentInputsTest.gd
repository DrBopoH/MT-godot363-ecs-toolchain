# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

class Recorder:
	extends Scheduler
	var heard: Array = []
	func input(channel: int, intent: int, value) -> void: heard.append([channel, intent, value])




func test_one_stream_becomes_intents() -> bool:
	var recorder: Recorder = Recorder.new()
	var inputs: IntentInputs = IntentInputs.new(recorder, {KEY_W: [6], BUTTON_LEFT: [2, 7], IntentInputs.MOTION: [1]}, 3)
	var key: InputEventKey = InputEventKey.new()
	key.scancode = KEY_W
	key.pressed = true
	inputs.capture(key)
	var echo: InputEventKey = InputEventKey.new()
	echo.scancode = KEY_W
	echo.pressed = true
	echo.echo = true
	inputs.capture(echo)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = BUTTON_LEFT
	click.pressed = false
	inputs.capture(click)
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(3, -1)
	inputs.capture(motion)
	var unbound: InputEventKey = InputEventKey.new()
	unbound.scancode = KEY_Q
	unbound.pressed = true
	inputs.capture(unbound)
	return recorder.heard == [[3, 6, true], [3, 2, false], [3, 7, false], [3, 1, Vector2(3, -1)]]

func test_input_queues_intents_for_the_tick() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.input(0, 6, true)
	scheduler.input(2, 1, Vector2(1, 0))
	return scheduler.composer.requests.inputs == [[0, 6, true], [2, 1, Vector2(1, 0)]]
