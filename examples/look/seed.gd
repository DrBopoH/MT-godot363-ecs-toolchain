# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Spatial

const FREECAM = preload("res://addons/MT-godot363-ecs-toolchain/content/blueprints/freecam.blueprint")
const BINDINGS = preload("res://addons/MT-godot363-ecs-toolchain/content/settings/bindings.blueprint")
const INTENTS: Dictionary = {"forward": 0, "back": 1, "left": 2, "right": 3, "fire": 4, "aim": 5, "look": 6, "up": 7, "down": 8}
const RATES: Array = [60, 30, 20]

var scheduler: Scheduler = Scheduler.new()
var inputs: IntentInputs = IntentInputs.new(scheduler, INTENTS, BINDINGS, "user://settings/bindings.blueprint")
var rate: int = 0


func _ready() -> void:
	scheduler.open(Intention, Latch.new(), [])
	scheduler.open(Looking, RelativeEuler.new(), [Trigger.new(6), Sensitivity.new(0.005), PitchLimits.new(Vector2(-86, 86))])
	scheduler.open(Conversion, DirectionFromIntents.new(), [Directions.new([3, 2, 7, 8, 0, 1])])
	scheduler.open(Thrust, LocalThrust.new(), [])
	scheduler.open(Movement, LinearMovement.new(), [])
	scheduler.open(Translator, DirectTranslator.new(), [])
	scheduler.open(Rotator, DirectRotator.new(), [])
	var camera: int = scheduler.composer.spawn(FREECAM)
	scheduler.composer.add(camera, Proxy.new($camera))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	report()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.scancode:
			KEY_F1: get_tree().physics_interpolation = not get_tree().physics_interpolation
			KEY_F2:
				rate = (rate + 1)%RATES.size()
				Engine.iterations_per_second = RATES[rate]
			KEY_ESCAPE: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
		report()
	inputs.capture(event)

func report() -> void:
	$hud.text = "F1 interpolation: %s    F2 ticks: %d    Esc mouse" % ["on" if get_tree().physics_interpolation else "off", Engine.iterations_per_second]


func _physics_process(delta: float) -> void: scheduler.physic(delta)
