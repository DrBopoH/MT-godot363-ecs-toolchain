# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name NetWire
extends Reference

enum {APPEAR, STATE, VANISH, JOIN, INPUT, TICKET}
enum {INBOX, OUTBOX}
enum {TARGET, RELIABLE, MESSAGES}

const HOST: int = 1
const EVERYONE: int = 0

var value: Array


func _init(_value: Array) -> void: value = _value
