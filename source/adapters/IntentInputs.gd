# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name IntentInputs
extends Reference

const MOTION: int = -1

var scheduler: Scheduler
var bindings: Dictionary
var channel: int


func _init(_scheduler: Scheduler, _bindings: Dictionary, _channel: int = 0) -> void:
	scheduler = _scheduler
	bindings = _bindings
	channel = _channel


func capture(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for intent in bindings.get(MOTION, []): scheduler.input(channel, intent, event.relative)
	elif (event is InputEventKey and not event.echo) or event is InputEventMouseButton:
		var code: int = event.button_index if event is InputEventMouseButton else event.scancode
		for intent in bindings.get(code, []): scheduler.input(channel, intent, event.pressed)
