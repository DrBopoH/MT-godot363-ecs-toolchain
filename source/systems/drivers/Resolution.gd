# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

class_name Resolution
extends Functor


func needs() -> Array: return [Held, Released, Durations, Clicked, Holding]

func owns() -> Array: return [Mask, Threshold]

func rate() -> int: return PHYSIC
