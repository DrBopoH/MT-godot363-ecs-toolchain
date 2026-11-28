# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

const suites: Array = [preload("SchedulerTest.gd"), preload("IntentInputsTest.gd"), preload("LatchTest.gd"), preload("ResolverTest.gd"), preload("DirectionTest.gd"), preload("ThrustTest.gd"), preload("LookTest.gd"), preload("ReplicationTest.gd")]


func _ready() -> void:
	var failed: int = 0
	for suite in suites:
		var instance: Reference = suite.new()
		for method in instance.get_method_list():
			if not method.name.begins_with("test_"): continue
			var passed: bool = instance.call(method.name)
			print(("ok   " if passed else "FAIL ") + method.name)
			if not passed: failed+= 1
	print("failed: %d" % failed)
