# Terrain3D Navigation Bake

This is a hacked together proof-of-concept as to what a navigation baker for [Terrain3D](https://github.com/outobugi/Terrain3D). It's incomplete and barely functional, but here's the rundown of the system:

In a broad view, it walks across the terrain, region by region, baking navmeshes in small chunks. It saves these chunks in a "bundle" resource, representing the entire terrain. Then, the user can use the bundle unpacker to put the navmeshes into the world.

Unfortunately, it is slow, and crashes a lot.

## How to use
1. Add a ChunkBaker node to the scene, and put everything you want baked underneath it like a regular navigation region.
2. Assign a folder for it to save the bundle into, point it at the terrain 3D, and then add a navigation mesh resource. This will be duplicated during the baking process, and so all meshes will use the settings here.
3. In the navmesh, under Filters/Baking AABB, Create an (Ideally power of 2) sized AABB to create the "chunk" that will scan the terrain. It scans in 3D only, so make it quite tall if your terrain has high peaks. Only the X and Z should ideally be a power of 2.
4. In the navmesh's Geometry/Parsed Geometry Type, use Static Colliders or Both.
5. Ensure that the debug collision on your terrain is turned on.
6. Click "Bake Terrain Navigation".
7. Assuming it doesn't crash, and you've drank a cup of tea, the bundle should now be saved.
8. In your scene, add a NavmeshBundleUnpacker node, select your bundle, and hit "unpack". All the navmeshes should now populate the scene.
