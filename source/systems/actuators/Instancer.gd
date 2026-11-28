# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Instancer
extends Embodiment


func enter(entity: int) -> void:
	var node: Node = tables[Scene][entity].instance()
	tables[Root][id].add_child(node)
	requests.appearing.append([entity, Proxy.new(node)])
