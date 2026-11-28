# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Scheduler
extends Reference

var pipeline: Pipeline = Pipeline.new()
var composer: Composer = Composer.new(pipeline)


func update(delta: float) -> void:
	pipeline.update(delta)
	composer.flush()


func open(position: GDScript, system: Functor, values) -> void:
	system.id = composer.components.spawn()
	own(system)
	for component in values: system.tables[component.get_script()][system.id] = component.value
	bind(system)
	composer.adopt(system)
	pipeline.open(position, system)

func swap(position: GDScript, system: Functor) -> void:
	var old: Functor = pipeline.swap(position, system)
	system.id = old.id
	system.subscribers = old.subscribers
	bind(system)

func own(system: Functor) -> void:
	for component in system.owns(): system.tables[component] = composer.components.declare(component)

func bind(system: Functor) -> void:
	own(system)
	for component in system.needs() + system.uses(): system.tables[component] = composer.components.declare(component)
	system.requests = composer.requests


func input(channel: int, intent: int, value) -> void: composer.requests.inputs.append([channel, intent, value])
