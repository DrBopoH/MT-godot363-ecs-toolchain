# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Reference

const DEFAULTS = preload("res://addons/MT-godot363-ecs-toolchain/content/settings/bindings.blueprint")
const INTENTS: Dictionary = {"forward": 0, "back": 1, "left": 2, "right": 3, "fire": 4, "aim": 5, "look": 6}
const USER: String = "user://tests/bindings.blueprint"

class Recorder:
	extends Scheduler
	var heard: Array = []
	func input(channel: int, intent: int, value) -> void: heard.append([channel, intent, value])


func press(inputs: IntentInputs, scancode: int) -> void:
	var key: InputEventKey = InputEventKey.new()
	key.scancode = scancode
	key.pressed = true
	inputs.capture(key)

func click(inputs: IntentInputs, button: int) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	inputs.capture(event)




func test_one_stream_becomes_intents() -> bool:
	Directory.new().remove(USER)
	var recorder: Recorder = Recorder.new()
	var inputs: IntentInputs = IntentInputs.new(recorder, INTENTS, DEFAULTS, USER, 3)
	press(inputs, KEY_W)
	press(inputs, KEY_UP)
	var echo: InputEventKey = InputEventKey.new()
	echo.scancode = KEY_W
	echo.pressed = true
	echo.echo = true
	inputs.capture(echo)
	click(inputs, BUTTON_LEFT)
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(3, -1)
	inputs.capture(motion)
	press(inputs, KEY_Q)
	return recorder.heard == [[3, 0, true], [3, 0, true], [3, 4, true], [3, 6, Vector2(3, -1)]]

func test_user_layer_overrides_one_intent() -> bool:
	var user: Blueprint = Blueprint.new()
	user.carriers = [Bindings.new({"fire": ["Space"]})]
	ResourceSaver.save(USER, user)
	var recorder: Recorder = Recorder.new()
	var inputs: IntentInputs = IntentInputs.new(recorder, INTENTS, DEFAULTS, USER)
	click(inputs, BUTTON_LEFT)
	press(inputs, KEY_SPACE)
	press(inputs, KEY_S)
	Directory.new().remove(USER)
	return recorder.heard == [[0, 4, true], [0, 1, true]]

func test_input_queues_intents_for_the_tick() -> bool:
	var scheduler: Scheduler = Scheduler.new()
	scheduler.input(0, 6, true)
	scheduler.input(2, 1, Vector2(1, 0))
	return scheduler.composer.requests.inputs == [[0, 6, true], [2, 1, Vector2(1, 0)]]

func test_blueprint_writes_and_reads_back() -> bool:
	var path: String = "user://tests/roundtrip.blueprint"
	var written: Blueprint = Blueprint.new()
	written.carriers = [Position.new(Vector3(1, 2, 3)), Lifetime.new(0.5), Target.new(7), Scene.new(preload("res://addons/MT-godot363-ecs-toolchain/examples/dispenser/crate.tscn"))]
	ResourceSaver.save(path, written)
	var read: Blueprint = ResourceLoader.load(path, "", true)
	var values: Array = []
	for carrier in read: values.append(carrier.value)
	Directory.new().remove(path)
	return values[0] == Vector3(1, 2, 3) and values[1] == 0.5 and values[2] == 7 and values[3].resource_path.ends_with("crate.tscn")
