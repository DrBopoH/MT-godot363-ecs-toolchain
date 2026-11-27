# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Scheduler
extends Reference

var physic: Pipeline = Pipeline.new()
var render: Pipeline = Pipeline.new()
var pipelines: Dictionary = {Functor.PHYSIC: physic, Functor.RENDER: render}
var composer: Composer = Composer.new(pipelines)


func physic(delta: float) -> void:
	physic.update(delta)
	composer.flush()

func render(delta: float) -> void: render.update(delta)


func open(position: GDScript, system: Functor, values) -> void:
	system.id = composer.components.spawn()
	bind(system)
	for component in values: system.tables[component.get_script()][system.id] = component.value
	composer.adopt(system)
	pipelines[system.rate()].open(position, system)

func swap(position: GDScript, system: Functor) -> void:
	var old: Functor = pipelines[system.rate()].swap(position, system)
	system.id = old.id
	system.subscribers = old.subscribers
	bind(system)

func bind(system: Functor) -> void:
	for component in system.needs() + system.owns() + system.uses(): system.tables[component] = composer.components.declare(component)
	system.requests = composer.requests


func input(_intent: int, _value) -> void: return
