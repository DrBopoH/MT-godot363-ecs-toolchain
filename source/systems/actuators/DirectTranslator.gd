# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name DirectTranslator
extends Translator


func update(_delta: float) -> void:
	var positions: Array = tables[Position]
	var proxies: Array = tables[Proxy]
	for subscriber in subscribers: proxies[subscriber].translation = positions[subscriber]
