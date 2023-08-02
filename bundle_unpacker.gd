@tool
class_name NavmeshBundleUnpacker
extends Node


@export var bundle:NavmeshBundle


func unpack() -> void:
	for nm in bundle.meshes:
		var region = NavigationRegion3D.new()
		region.navigation_mesh = nm
		region.owner = get_tree().edited_scene_root
		add_child(region)
