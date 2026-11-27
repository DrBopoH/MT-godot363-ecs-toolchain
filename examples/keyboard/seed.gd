# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Spatial

const PILOT = preload("res://addons/MT-godot363-ecs-toolchain/content/blueprints/pilot.blueprint")
const BINDINGS = preload("res://addons/MT-godot363-ecs-toolchain/content/settings/bindings.blueprint")
const INTENTS: Dictionary = {"forward": 0, "back": 1, "left": 2, "right": 3, "fire": 4, "aim": 5, "look": 6, "up": 7, "down": 8}

var scheduler: Scheduler = Scheduler.new()
var inputs: IntentInputs = IntentInputs.new(scheduler, INTENTS, BINDINGS, "user://settings/bindings.blueprint")


func _ready() -> void:
	scheduler.open(Intention, Latch.new(), [])
	scheduler.open(Conversion, DirectionFromIntents.new(), [Directions.new([3, 2, 7, 8, 0, 1])])
	scheduler.open(Thrust, DirectThrust.new(), [])
	scheduler.open(Movement, LinearMovement.new(), [])
	scheduler.open(Translator, DirectTranslator.new(), [])
	var pilot: int = scheduler.composer.spawn(PILOT)
	scheduler.composer.add(pilot, Proxy.new($craft))

func _unhandled_input(event: InputEvent) -> void: inputs.capture(event)

func _physics_process(delta: float) -> void: scheduler.physic(delta)
