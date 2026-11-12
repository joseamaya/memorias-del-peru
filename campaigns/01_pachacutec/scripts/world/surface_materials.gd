class_name SurfaceMaterials
extends RefCounted
## Materiales con texturas de detalle para la llacta (alcance §6.2): un solo
## shader triplanar sobre dos Texture2DArray de shared_assets. Los modelos
## eligen la capa por la clase de superficie que escribe el generador de
## Blender; el terreno, los muros y las cajas usan una capa fija.

## Capas del array, en el orden de shared_assets/textures (LICENSE.md).
enum Layer { STONE, PLASTER, THATCH, WOOD, FABRIC, GRASS, DIRT, ROCK, SOIL }

const SHADER_PATH: String = "res://shared_assets/materials/superficie_triplanar.gdshader"
const DETAIL_PATH: String = "res://shared_assets/textures/superficies_detalle.webp"
const NORMAL_PATH: String = "res://shared_assets/textures/superficies_normal.webp"
## Repeticiones por metro de cada capa, en el orden de [enum Layer].
const LAYER_SCALES: PackedFloat32Array = [0.7, 0.5, 0.7, 1.0, 3.0, 0.25, 0.35, 0.15, 0.3]
const MAX_OVERLAY_RECTS: int = 8
## Material que el generador de personajes pone a la ropa (ADR-0016).
const CLOTH_MATERIAL_NAME: String = "pch_cloth"
## Repeticiones por metro del tejido de la ropa (las coordenadas UV2 van en
## metros).
const CLOTH_SCALE: float = 9.0
## La trama del tejido, más suave que en piedra o paja: de cerca, la ropa no
## debe parecer un saco.
const CLOTH_DETAIL: float = 0.55
## Umbral de recorte del pelo y las cejas.
const HAIR_ALPHA_SCISSOR: float = 0.4

static var _model_material: ShaderMaterial = null
static var _cloth_material: ShaderMaterial = null


## Material compartido de los modelos generados: capa según la clase de
## superficie, color por vértice y proyección en coordenadas del objeto.
static func model_material() -> ShaderMaterial:
	if _model_material == null:
		_model_material = _base_material()
	return _model_material


## Material compartido de la ropa de los personajes: tejido por UV2 y color
## por vértice.
static func cloth_material() -> ShaderMaterial:
	if _cloth_material == null:
		_cloth_material = _base_material()
		_cloth_material.set_shader_parameter("cloth_uv2", true)
		_cloth_material.set_shader_parameter("detail_strength", CLOTH_DETAIL)
		var scales: PackedFloat32Array = LAYER_SCALES.duplicate()
		scales[Layer.FABRIC] = CLOTH_SCALE
		_cloth_material.set_shader_parameter("layer_scale", scales)
	return _cloth_material


## Material de la vegetación generada: como [method model_material], y además
## se mece con el viento. [param bend] es la flexión por metro² de altura.
static func vegetation_material(bend: float) -> ShaderMaterial:
	var material: ShaderMaterial = _base_material()
	material.set_shader_parameter("wind_bend", bend)
	return material


## Material de capa fija [param layer] con [param tint] lineal. Con
## [param use_vertex_color], el tinte multiplica el color por vértice.
static func layer_material(layer: Layer, tint: Color, use_vertex_color: bool = false) -> ShaderMaterial:
	var material: ShaderMaterial = _base_material()
	material.set_shader_parameter("fixed_layer", int(layer))
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("use_vertex_color", use_vertex_color)
	material.set_shader_parameter("world_projection", true)
	return material


## Terreno: hierba con [param grass_tint], roca con [param rock_tint] en las
## pendientes y en lo alto, y tierra con [param dirt_tint] en las zonas que
## fija [method set_overlay_areas].
static func terrain_material(grass_tint: Color, rock_tint: Color, dirt_tint: Color) -> ShaderMaterial:
	var material: ShaderMaterial = layer_material(Layer.GRASS, grass_tint)
	material.set_shader_parameter("steep_layer", int(Layer.ROCK))
	material.set_shader_parameter("steep_tint", rock_tint)
	material.set_shader_parameter("overlay_layer", int(Layer.DIRT))
	material.set_shader_parameter("overlay_tint", dirt_tint)
	material.set_shader_parameter("macro_strength", 0.45)
	return material


## Zonas de tierra del terreno: cada [MeshInstance3D] con [BoxMesh] aporta su
## rectángulo en planta (sin giro). Devuelve cuántas zonas quedaron.
static func set_overlay_areas(material: ShaderMaterial, boxes: Array[MeshInstance3D]) -> int:
	var rects: Array[Vector4] = []
	for box_instance: MeshInstance3D in boxes:
		var box: BoxMesh = box_instance.mesh as BoxMesh
		if box == null or rects.size() >= MAX_OVERLAY_RECTS:
			continue
		var center: Vector3 = box_instance.global_position if box_instance.is_inside_tree() else box_instance.position
		rects.append(Vector4(center.x, center.z, box.size.x * 0.5, box.size.z * 0.5))
	while rects.size() < MAX_OVERLAY_RECTS:
		rects.append(Vector4.ZERO)
	var count: int = 0
	for rect: Vector4 in rects:
		if rect.z > 0.0:
			count += 1
	material.set_shader_parameter("overlay_rects", rects)
	material.set_shader_parameter("overlay_rect_count", count)
	return count


## Pone los materiales del proyecto en las mallas bajo [param root]:
## - modelos de `pch_models.py` (una superficie sin material propio y con la
##   clase de superficie en UV): [method model_material] en toda la malla;
## - personajes de `pch_people.py` (ADR-0016): [method cloth_material] en la
##   ropa, y recorte por alfa en el pelo y las cejas; la piel y los ojos
##   conservan su material importado.
## Devuelve cuántas mallas cambió.
static func apply_to_model(root: Node) -> int:
	if root == null:
		return 0
	var changed: int = 0
	var meshes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.append(root)
	for node: Node in meshes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		var array_mesh: ArrayMesh = mesh_instance.mesh as ArrayMesh
		if array_mesh == null:
			continue
		if has_surface_class(array_mesh) and not _is_named(array_mesh.surface_get_material(0)):
			mesh_instance.material_override = model_material()
			changed += 1
			continue
		var touched: bool = false
		for surface: int in range(array_mesh.get_surface_count()):
			var material: Material = array_mesh.surface_get_material(surface)
			if material != null and material.resource_name == CLOTH_MATERIAL_NAME:
				mesh_instance.set_surface_override_material(surface, cloth_material())
				touched = true
			elif material is BaseMaterial3D and material.resource_name.ends_with(".body"):
				# Piel: algo de brillo suave y luz de borde, que la aleja del
				# aspecto de cera o de barro.
				mesh_instance.set_surface_override_material(surface, _skin(material as BaseMaterial3D))
				touched = true
			elif material is BaseMaterial3D and material.resource_name.ends_with(".low-poly"):
				# Ojos: húmedos, con reflejo; sin él la mirada parece muerta.
				var eyes: BaseMaterial3D = (material as BaseMaterial3D).duplicate() as BaseMaterial3D
				eyes.roughness = 0.08
				eyes.metallic_specular = 0.9
				mesh_instance.set_surface_override_material(surface, eyes)
				touched = true
			elif material is BaseMaterial3D and (material as BaseMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				# Pelo y cejas: recorte sin mezcla, para no tener problemas de
				# orden; las tarjetas del pelo se ven por las dos caras.
				var hair: BaseMaterial3D = (material as BaseMaterial3D).duplicate() as BaseMaterial3D
				hair.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				hair.alpha_scissor_threshold = HAIR_ALPHA_SCISSOR
				hair.cull_mode = BaseMaterial3D.CULL_DISABLED
				mesh_instance.set_surface_override_material(surface, hair)
				touched = true
		if touched:
			changed += 1
	return changed


static func _skin(material: BaseMaterial3D) -> BaseMaterial3D:
	var skin: BaseMaterial3D = material.duplicate() as BaseMaterial3D
	skin.roughness = 0.58
	skin.metallic_specular = 0.45
	skin.rim_enabled = true
	skin.rim = 0.22
	skin.rim_tint = 0.65
	return skin


static func _is_named(material: Material) -> bool:
	return material != null and not material.resource_name.is_empty()


## Verdadero si la primera superficie de [param mesh] trae UV (la clase de
## superficie del generador).
static func has_surface_class(mesh: Mesh) -> bool:
	var array_mesh: ArrayMesh = mesh as ArrayMesh
	if array_mesh == null or array_mesh.get_surface_count() == 0:
		return false
	return (array_mesh.surface_get_format(0) & Mesh.ARRAY_FORMAT_TEX_UV) != 0


static func _base_material() -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(SHADER_PATH) as Shader
	material.set_shader_parameter("detail_array", load(DETAIL_PATH) as TextureLayered)
	material.set_shader_parameter("normal_array", load(NORMAL_PATH) as TextureLayered)
	material.set_shader_parameter("layer_scale", LAYER_SCALES)
	return material
