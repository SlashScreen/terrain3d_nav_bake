@tool
class_name ChunkBaker
extends NavigationRegion3D


@export var navmesh_template:NavigationMesh
@export_dir() var bake_path:String
@export var terrain:Terrain3D
@export_range(0, 100, 1, "or_greater") var bake_region:int
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
var bake_thread:Thread

signal bake_started
signal bake_ended


## Bakes a navigation mesh group for a [class Terrain3D], and any child nodes as usual. It wraps it in a [class NavmeshBundle] and saves it to disk.
func bake_terrain() -> void:
	print("Starting bake.")
	#bake_started.emit()
	print("Initializing bundles.")
	bundle = NavmeshBundle.new()
	
	if navigation_mesh == null:
		navigation_mesh = navmesh_template.duplicate()
	
	print("Processing region.")
	#bake_thread = Thread.new()
	#bake_thread.start(_loop_thread.bind())
	_loop_thread()
	# Save bundle to disk.


func _scan() -> void:
	print("duplicating mesh")
	navigation_mesh = navmesh_template.duplicate()
	print("Changing AABB")
	var aabb:AABB = navigation_mesh.filter_baking_aabb
	navigation_mesh.filter_baking_aabb = aabb.grow(navmesh_template.agent_radius) # grow to get rid of edge
	navigation_mesh.filter_baking_aabb_offset = pos_offet
	print("Baking chunk...")
	bake_navigation_mesh()
	print("Chunk finished.")
	await bake_finished


func stop() -> void:
	stop_it = true
	bake_thread.wait_to_finish()
	stop_it = false


func _wrap_up() -> void:
	ResourceSaver.save(bundle, "%s/%s_bundle.tres" % [bake_path, name])
	print("Finished baking.")


func _loop_thread() -> void:
	var offsets = region_offsets
	var region_uv = offsets[bake_region]
	# Grab region info
	var region_center:Vector2 = region_uv*region_size
	#var region_index = terrain.storage.get_region_index(Vector3(region_center.x, 0, region_center.y))
	var xz:Rect2 = Rect2(region_center.x - region_size*.5, region_center.y - region_size*.5, region_size, region_size)
	var aabb:AABB = navmesh_template.filter_baking_aabb
	
	#print("Processing region %s of %s." % [region_index, offsets.size()])
	var total = range(xz.position.x, xz.end.x, aabb.size.x).size() * range(xz.position.y, xz.end.y, aabb.size.z).size() # can i not do math
	var i = 1
	# Bake each chunk.
	for x in range(xz.position.x, xz.end.x, aabb.size.x):
		for y in range(xz.position.y, xz.end.y, aabb.size.z):
			if stop_it:
				bake_ended.emit()
				return
			
			pos_offet = Vector3(x, 0, y)
			print(pos_offet)
			
			print("duplicating mesh")
			navigation_mesh = navmesh_template.duplicate()
			print("Changing AABB")
			var agent_diameter = navmesh_template.agent_radius * 2
			navigation_mesh.filter_baking_aabb.size = (navigation_mesh.filter_baking_aabb as AABB).size + Vector3(agent_diameter, 0, agent_diameter)
			print((navigation_mesh.filter_baking_aabb as AABB).size + Vector3(agent_diameter, 0, agent_diameter))
			print((navigation_mesh.filter_baking_aabb as AABB).size)
			navigation_mesh.filter_baking_aabb_offset = pos_offet
			print("Baking chunk...")
			bake_navigation_mesh()
			print("Chunk finished.")
			await bake_finished
			
			#ResourceSaver.save(navigation_mesh, "%s/%s.tres" % [bake_path, pos_offet])
			bundle.meshes.append(navigation_mesh)
			
			print("Region Progress: %s / %s" % [i, total])
			i += 1
	
	_wrap_up()
