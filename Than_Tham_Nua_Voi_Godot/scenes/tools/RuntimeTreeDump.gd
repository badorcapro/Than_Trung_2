extends Node

const TARGET_OUTPUT_REL: String = "../docs/agent-system/evidence/godot/runtime_scene_tree.json"

func _ready() -> void:
	# Allow autoloads and frame pipeline to settle
	await get_tree().process_frame
	
	# Instantiate Boot.tscn to capture real gameplay/ui runtime structure
	var boot_scene_res: PackedScene = load("res://scenes/boot/Boot.tscn")
	var boot_instance: Node = null
	if boot_scene_res:
		boot_instance = boot_scene_res.instantiate()
		add_child(boot_instance)
		await get_tree().process_frame
	
	_dump_tree(boot_instance)

func _dump_tree(boot_instance: Node) -> void:
	var root: Node = get_tree().root
	var autoloads: Array = []
	
	for child in root.get_children():
		if child != self:
			var script_path: String = ""
			if child.get_script():
				script_path = (child.get_script() as Script).resource_path
			autoloads.append({
				"name": child.name,
				"class_name": child.get_class(),
				"script_path": script_path,
				"node_path": str(child.get_path()),
				"is_autoload": true
			})
			
	var tree_data: Dictionary = {
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"engine_version": Engine.get_version_info(),
		"autoload_singletons": autoloads,
		"root_node": _dump_node(root)
	}
	
	var json_str: String = JSON.stringify(tree_data, "  ")
	var res_base: String = ProjectSettings.globalize_path("res://")
	var full_out: String = res_base.path_join(TARGET_OUTPUT_REL).simplify_path()
	
	var file := FileAccess.open(full_out, FileAccess.WRITE)
	if file:
		file.store_string(json_str + "\n")
		file.close()
		print("[RuntimeTreeDump] Successfully written runtime scene tree to: ", full_out)
	else:
		printerr("[RuntimeTreeDump] Failed to write to: ", full_out)
		
	# Clean exit within windowed mode
	get_tree().quit(0)

func _dump_node(node: Node) -> Dictionary:
	var script_path: String = ""
	if node.get_script():
		script_path = (node.get_script() as Script).resource_path
		
	var groups_list: Array = []
	for g in node.get_groups():
		groups_list.append(str(g))
		
	var children_data: Array = []
	for child in node.get_children():
		children_data.append(_dump_node(child))
		
	return {
		"name": node.name,
		"class_name": node.get_class(),
		"node_path": str(node.get_path()),
		"scene_file_path": node.scene_file_path,
		"script_path": script_path,
		"groups": groups_list,
		"children_count": children_data.size(),
		"children": children_data
	}
