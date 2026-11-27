# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name IntentInputs
extends Reference

const MOTION: int = -1
const MOUSE: Dictionary = {
	"Mouse_L": BUTTON_LEFT,
	"Mouse_R": BUTTON_RIGHT,
	"Mouse_M": BUTTON_MIDDLE,
	"Wheel_Up": BUTTON_WHEEL_UP,
	"Wheel_Down": BUTTON_WHEEL_DOWN,
	"Motion": MOTION
}

var scheduler: Scheduler
var bindings: Dictionary = {}
var channel: int


func _init(_scheduler: Scheduler, intents: Dictionary, defaults: Blueprint, overrides: String, _channel: int = 0) -> void:
	scheduler = _scheduler
	channel = _channel
	var keys: Dictionary = layer(defaults)
	if ResourceLoader.exists(overrides):
		var user: Dictionary = layer(ResourceLoader.load(overrides, "", true))
		for intent in user: keys[intent] = user[intent]
	for intent in keys:
		for key in keys[intent]:
			var code: int = MOUSE[key] if MOUSE.has(key) else OS.find_scancode_from_string(key)
			bindings[code] = bindings.get(code, []) + [intents[intent]]

func layer(blueprint: Blueprint) -> Dictionary:
	for carrier in blueprint:
		if carrier is Bindings: return carrier.value.duplicate()
	return {}


func capture(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for intent in bindings.get(MOTION, []): scheduler.input(channel, intent, event.relative)
	elif (event is InputEventKey and not event.echo) or event is InputEventMouseButton:
		var code: int = event.button_index if event is InputEventMouseButton else event.scancode
		for intent in bindings.get(code, []): scheduler.input(channel, intent, event.pressed)
