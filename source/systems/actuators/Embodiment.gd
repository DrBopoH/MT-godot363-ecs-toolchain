# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Embodiment
extends Functor


func needs() -> Array: return [Scene]

func owns() -> Array: return [Root]

func uses() -> Array: return [Proxy]

func rate() -> int: return PHYSIC

func exit(entity: int) -> void: tables[Proxy][entity].queue_free()
