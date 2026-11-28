# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
class_name BlueprintSaver
extends ResourceFormatSaver


func get_recognized_extensions(_resource: Resource) -> PoolStringArray: return PoolStringArray(["blueprint"])

func recognize(resource: Resource) -> bool: return resource is Blueprint

func save(path: String, resource: Resource, _flags: int) -> int:
	var names: Dictionary = {}
	for entry in ProjectSettings.get_setting("_global_script_classes"): names[entry["path"]] = entry["class"]
	var data: Dictionary = {}
	for carrier in resource: data[names[carrier.get_script().resource_path]] = encode(carrier.value)
	Directory.new().make_dir_recursive(path.get_base_dir())
	var file: File = File.new()
	var error: int = file.open(path, File.WRITE)
	if error != OK: return error
	file.store_string(JSON.print(data, "\t"))
	file.close()
	return OK


func encode(value):
	match typeof(value):
		TYPE_VECTOR3: return [value.x, value.y, value.z]
		TYPE_OBJECT: return value.resource_path
	return value
