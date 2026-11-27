# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Components
extends Reference

var capacity: int = 1024
var count: int = 0
var tables: Dictionary = {}
var free: Array = []
var links: Array = []
var events: Array = []


func declare(component: GDScript) -> Array:
	if not tables.has(component):
		var table: Array = []
		table.resize(capacity)
		tables[component] = table
		if component.get_base_script() == Link: links.append(component)
		if component.get_base_script() == Event: events.append(component)
	return tables[component]

func table(component: GDScript) -> Array:
	return tables[component]


func spawn() -> int:
	if not free.empty(): return free.pop_back()
	if count == capacity: grow()
	var id: int = count
	count+= 1
	return id

func release(id: int) -> void: free.append(id)

func grow() -> void:
	capacity*= 2
	for component in tables: tables[component].resize(capacity)
