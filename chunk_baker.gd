@tool
class_name ChunkBaker
extends NavigationRegion3D


@export var navmesh_template:NavigationMesh
@export_dir() var bake_path:String
@export var terrain:Terrain3D
var pos_offet:Vector3
var region_done:bool
var bundle:NavmeshBundle
var region_offsets:Array[Vector2i]:
	get:
		return terrain.storage.data_region_offsets
var region_size:int:
	get:
		return terrain.storage.region_size
var stop_it:bool

signal bake_started
signal bake_ended


## Bakes a navigation mesh group for a [class Terrain3D], and any child nodes as usual. It wraps it in a [class NavmeshBundle] and saves it to disk.
func bake_terrain() -> void:
	bake_started.emit()
	bundle = NavmeshBundle.new()
	var offsets = region_offsets
	
	if navigation_mesh == null:
		navigation_mesh = navmesh_template.duplicate()
	
	for region_uv in offsets:
		# Grab region info
		var region_center:Vector2 = region_uv*region_size
		var region_index = terrain.storage.get_region_index(Vector3(region_center.x, 0, region_center.y))
		var xz:Rect2 = Rect2(region_center.x - region_size*.5, region_center.y - region_size*.5, region_size, region_size)
		var aabb:AABB = navigation_mesh.filter_baking_aabb
		
		print("Processing region %s of %s." % [region_index, offsets.size()])
		# Bake each chunk.
		for x in range(xz.position.x, xz.end.x, aabb.size.x):
			for y in range(xz.position.y, xz.end.y, aabb.size.z):
				if stop_it:
					stop_it = false
					bake_ended.emit()
					return
				
				pos_offet = Vector3(x, 0, y)
				print(pos_offet)
				_scan()
				await bake_finished
	# Save bundle to disk.
	ResourceSaver.save(bundle, "%s/%s_bundle.tres" % [bake_path, name])
	bake_ended.emit()


func _scan() -> void:
	navigation_mesh = navmesh_template.duplicate()
	
	var aabb:AABB = navigation_mesh.filter_baking_aabb
	navigation_mesh.filter_baking_aabb_offset = pos_offet
	
	bake_navigation_mesh()
	bundle.meshes.append(navigation_mesh)
