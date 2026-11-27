# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Expiry
extends Aging


func update(delta: float) -> void:
	var lifetimes: Array = tables[Lifetime]
	for subscriber in subscribers:
		lifetimes[subscriber]-= delta
		if lifetimes[subscriber] <= 0.0: requests.dying.append(subscriber)
