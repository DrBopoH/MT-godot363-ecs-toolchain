class_name Instancer
extends Embodiment


func enter(entity: int) -> void:
	var node: Node = tables[Scene][entity].instance()
	tables[Root][id].add_child(node)
	appearing.append([entity, Proxy.new(node)])
