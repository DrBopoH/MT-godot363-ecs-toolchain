# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Functor
extends Reference

enum {PHYSIC, RENDER}

var id: int = 0
var subscribers: Array = []
var tables: Dictionary = {}
var requests: Requests


func needs() -> Array: return []

func owns() -> Array: return []

func uses() -> Array: return []

func rate() -> int: return -1

func update(_delta: float) -> void: return

func enter(_id: int) -> void: return

func exit(_id: int) -> void: return
