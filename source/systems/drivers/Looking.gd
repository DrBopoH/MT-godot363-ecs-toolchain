# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Looking
extends Functor


func needs() -> Array: return [Axes, Orientation]

func owns() -> Array: return [Trigger, Sensitivity, PitchLimits]
