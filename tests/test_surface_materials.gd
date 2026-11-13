extends RefCounted
## Comprueba las texturas de detalle (alcance §6.2, ADR-0014): los arrays se
## cargan con sus nueve capas, los modelos generados traen la clase de
## superficie y reciben el material compartido, y el terreno pinta la tierra
## de la plaza y los cuatro caminos en lugar de mostrar las losas.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const HOUSE_MODEL: String = "res://campaigns/01_pachacutec/assets/models/pch_house_a.glb"
const LAYER_COUNT: int = 9


func test_texture_arrays_load() -> bool:
	var detail: TextureLayered = load(SurfaceMaterials.DETAIL_PATH) as TextureLayered
	var normal: TextureLayered = load(SurfaceMaterials.NORMAL_PATH) as TextureLayered
	if detail == null or normal == null:
		return false
	return (
		detail.get_layers() == LAYER_COUNT
		and normal.get_layers() == LAYER_COUNT
		and SurfaceMaterials.LAYER_SCALES.size() == LAYER_COUNT
		and SurfaceMaterials.LAYER_TINTS.size() == LAYER_COUNT
		and SurfaceMaterials.Layer.size() == LAYER_COUNT
	)


## La casa generada trae clases de piedra, barro y paja en UV.x.
func test_model_carries_surface_classes() -> bool:
	var packed: PackedScene = load(HOUSE_MODEL) as PackedScene
	if packed == null:
		return false
	var model: Node = packed.instantiate()
	var found: Array[Node] = model.find_children("*", "MeshInstance3D", true, false)
	var classes: Dictionary[int, bool] = {}
	var ok: bool = not found.is_empty()
	if ok:
		var mesh: Mesh = (found[0] as MeshInstance3D).mesh
		ok = SurfaceMaterials.has_surface_class(mesh)
		if ok:
			var arrays: Array = mesh.surface_get_arrays(0)
			var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			for uv: Vector2 in uvs:
				classes[int(roundf(uv.x))] = true
	model.free()
	var stone: int = int(SurfaceMaterials.Layer.STONE) + 1
	var plaster: int = int(SurfaceMaterials.Layer.PLASTER) + 1
	var thatch: int = int(SurfaceMaterials.Layer.THATCH) + 1
	return ok and classes.has(stone) and classes.has(plaster) and classes.has(thatch)


func test_world_uses_surface_materials() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var model_meshes: int = 0
	var textured_models: int = 0
	for node: Node in world.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		# Los personajes (ADR-0016) traen materiales con nombre: piel, ojos,
		# pelo y ropa; esos no usan el material de modelo.
		var first: Material = mesh_instance.mesh.surface_get_material(0) if mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0 else null
		if first != null and not first.resource_name.is_empty():
			continue
		if SurfaceMaterials.has_surface_class(mesh_instance.mesh):
			model_meshes += 1
			if mesh_instance.material_override == SurfaceMaterials.model_material():
				textured_models += 1
	var terrain: MeshInstance3D = world.get_node_or_null("Terrain/TerrainMesh") as MeshInstance3D
	var terrain_material: ShaderMaterial = terrain.material_override as ShaderMaterial if terrain != null else null
	var overlay_count: int = -1
	if terrain_material != null:
		var count: Variant = terrain_material.get_shader_parameter("overlay_rect_count")
		if count is int:
			overlay_count = count
	var plaza: MeshInstance3D = world.get_node_or_null("Llacta/Plaza") as MeshInstance3D
	var ok: bool = (
		model_meshes > 0
		and textured_models == model_meshes
		and overlay_count == 5
		and plaza != null
		and not plaza.visible
	)
	world.free()
	return ok
