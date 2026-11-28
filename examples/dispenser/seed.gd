# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Spatial

const CRATE = preload("res://addons/MT-godot363-ecs-toolchain/content/blueprints/crate.blueprint")

var scheduler: Scheduler = Scheduler.new()


func _ready() -> void:
	scheduler.open(Translator, DirectTranslator.new(), [])
	scheduler.open(Embodiment, Instancer.new(), [Root.new(self)])
	scheduler.open(Aging, Expiry.new(), [])
	scheduler.open(Emission, Periodic.new(), [
		Interval.new(1.0),
		Countdown.new(0.0),
		Template.new(CRATE)
	])

func _physics_process(delta: float) -> void: scheduler.update(delta)
