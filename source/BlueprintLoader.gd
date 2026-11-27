class_name BlueprintLoader
extends ResourceFormatLoader


func get_recognized_extensions() -> PoolStringArray: return PoolStringArray(["blueprint"])

func get_resource_type(path: String) -> String: return "Resource" if path.get_extension() == "blueprint" else ""

func handles_type(type: String) -> bool: return type == "Resource"

func load(path: String, _original_path: String, _no_subresource_cache: bool = false):
	var file: File = File.new()
	file.open(path, File.READ)
	var data: Dictionary = parse_json(file.get_as_text())
	file.close()
	var scripts: Dictionary = {}
	for entry in ProjectSettings.get_setting("_global_script_classes"): scripts[entry["class"]] = entry["path"]
	var blueprint: Blueprint = Blueprint.new()
	for name in data:
		var component: GDScript = load(scripts[name])
		blueprint.carriers.append(component.new(decode(component, data[name])))
	return blueprint


func decode(component: GDScript, raw):
	for property in component.get_script_property_list():
		if property.name != "value": continue
		match property.type:
			TYPE_VECTOR3: return Vector3(raw[0], raw[1], raw[2])
			TYPE_INT: return int(raw)
			TYPE_REAL: return float(raw)
			TYPE_BOOL: return bool(raw)
			TYPE_OBJECT: return load(raw)
	return raw
