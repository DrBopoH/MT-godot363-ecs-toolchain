# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Spatial

var scheduler: Scheduler = Scheduler.new()


func _ready() -> void:
	scheduler.open(Translator, DirectTranslator.new(), [])
	scheduler.composer.spawn([Position.new(Vector3(0, 0, -5)), Proxy.new($craft)])

func _physics_process(delta: float) -> void: scheduler.update(delta)
