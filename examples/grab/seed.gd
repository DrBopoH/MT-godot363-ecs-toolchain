# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Spatial

const BINDINGS = preload("res://addons/MT-godot363-ecs-toolchain/content/settings/bindings.blueprint")
const INTENTS: Dictionary = {"forward": 0, "back": 1, "left": 2, "right": 3, "fire": 4, "aim": 5, "look": 6, "up": 7, "down": 8}

var scheduler: Scheduler = Scheduler.new()
var inputs: IntentInputs = IntentInputs.new(scheduler, INTENTS, BINDINGS, "user://settings/bindings.blueprint")


func _ready() -> void:
	scheduler.open(Intention, Latch.new(), [])
	scheduler.open(Picking, RaycastPicker.new(), [Trigger.new(4)])
	scheduler.open(Pointing, CursorAnchor.new(), [])
	scheduler.open(Springing, SpringFollow.new(), [Strength.new(25.0)])
	scheduler.open(Conversion, DirectionFromIntents.new(), [Directions.new([3, 2, 7, 8, 0, 1])])
	scheduler.open(Thrust, DirectThrust.new(), [])
	scheduler.open(Movement, LinearMovement.new(), [])
	scheduler.open(Translator, DirectTranslator.new(), [])
	scheduler.composer.spawn([
		Controlled.new(0), Held.new(0), Pressed.new(0), Released.new(0), Axes.new({}),
		Direction.new(Vector3.ZERO), Speed.new(4.0), Velocity.new(Vector3.ZERO),
		Position.new($camera.translation), Proxy.new($camera)
	])
	for body in $bodies.get_children(): scheduler.composer.spawn([Proxy.new(body)])

func _unhandled_input(event: InputEvent) -> void: inputs.capture(event)

func _physics_process(delta: float) -> void: scheduler.update(delta)
