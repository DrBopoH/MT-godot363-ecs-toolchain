# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Spatial

var scheduler: Scheduler = Scheduler.new()


func _ready() -> void:
	scheduler.open(Movement, LinearMovement.new(), [])
	scheduler.open(Following, AnchorFollow.new(), [])
	scheduler.open(Aging, Expiry.new(), [])
	scheduler.open(Embodiment, Instancer.new(), [Root.new(self)])
	scheduler.open(Translator, DirectTranslator.new(), [])
	var anchor: int = scheduler.composer.spawn([
		Position.new(Vector3(-2, 0, -6)),
		Velocity.new(Vector3(1, 0, 0)),
		Lifetime.new(3.0),
		Scene.new(preload("anchor.tscn"))
	])
	scheduler.composer.spawn([
		Position.new(Vector3(-2, -1.5, -6)),
		Target.new(anchor),
		Offset.new(Vector3(0, -1.5, 0)),
		Scene.new(preload("body.tscn"))
	])

func _physics_process(delta: float) -> void: scheduler.update(delta)
