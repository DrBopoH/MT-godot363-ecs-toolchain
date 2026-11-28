# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name DirectRotator
extends Rotator


func update(_delta: float) -> void:
	var orientations: Array = tables[Orientation]
	var proxies: Array = tables[Proxy]
	for subscriber in subscribers: proxies[subscriber].rotation = orientations[subscriber]

func enter(entity: int) -> void:
	var proxy: Spatial = tables[Proxy][entity]
	proxy.rotation = tables[Orientation][entity]
	proxy.reset_physics_interpolation()
