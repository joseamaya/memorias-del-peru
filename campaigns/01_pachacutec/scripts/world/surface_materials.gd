class_name SurfaceMaterials
extends RefCounted
## Materiales con texturas de detalle para la llacta (alcance §6.2): un solo
## shader triplanar sobre dos Texture2DArray de shared_assets. Los modelos
## eligen la capa por la clase de superficie que escribe el generador de
## Blender; el terreno, los muros y las cajas usan una capa fija.

## Capas del array, en el orden de shared_assets/textures (LICENSE.md).
enum Layer { STONE, PLASTER, THATCH, WOOD, FABRIC, GRASS, DIRT, ROCK, SOIL }

const SHADER_PATH: String = "res://shared_assets/materials/superficie_triplanar.gdshader"
## La ropa usa la misma superficie dibujada por las dos caras.
const CLOTH_SHADER_PATH: String = "res://shared_assets/materials/superficie_tela.gdshader"
const DETAIL_PATH: String = "res://shared_assets/textures/superficies_detalle.webp"
const NORMAL_PATH: String = "res://shared_assets/textures/superficies_normal.webp"
## Repeticiones por metro de cada capa, en el orden de [enum Layer].
##
## Las capas de terreno y muro van finas a propósito: con una repetición cada
## 3 m el barro se leía como manchas de un metro y la piedra como blobs
## blancos. A escala de grano el patrón deja de verse y la variación de gran
## escala (macro) rompe la repetición.
const LAYER_SCALES: PackedFloat32Array = [1.6, 1.1, 1.2, 1.0, 3.0, 0.5, 1.2, 0.8, 1.4]
## Corrección de color por clase (alfa = intensidad), en el orden de [enum Layer].
## Atenúa los tintes de los modelos generados sin volver a exportarlos.
const LAYER_TINTS: Array[Color] = [
	Color(0.62, 0.60, 0.56, 0.35),
	Color(0.58, 0.54, 0.48, 0.5),
	Color(0.55, 0.44, 0.24, 0.3),
	Color(1.0, 1.0, 1.0, 0.0),
	Color(1.0, 1.0, 1.0, 0.0),
	Color(1.0, 1.0, 1.0, 0.0),
	Color(1.0, 1.0, 1.0, 0.0),
	Color(1.0, 1.0, 1.0, 0.0),
	Color(1.0, 1.0, 1.0, 0.0),
]
const MAX_OVERLAY_RECTS: int = 8
## Material que el generador de personajes pone a la ropa (ADR-0016).
const CLOTH_MATERIAL_NAME: String = "pch_cloth"
## Cuánto se apaga el color de la ropa (0 = tal cual, 1 = gris).
const CLOTH_DESATURATION: float = 0.22
## Repeticiones por metro del tejido de la ropa (las coordenadas UV2 van en
## metros). La lana de la capa de tejido (Fabric031) tiene unas 180 puntadas
## por repetición: cada 33 cm da unos 5 hilos por centímetro.
const CLOTH_SCALE: float = 3.0
## La trama del tejido, más suave que en piedra o paja: de cerca, la ropa no
## debe parecer un saco.
const CLOTH_DETAIL: float = 0.72
## Umbral de recorte del pelo y las cejas.
const HAIR_ALPHA_SCISSOR: float = 0.4

static var _model_material: ShaderMaterial = null
static var _cloth_material: ShaderMaterial = null
## Materiales de ropa con textil propio, uno por textura de personaje.
static var _textile_materials: Dictionary[Texture2D, ShaderMaterial] = {}


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
		_cloth_material.shader = load(CLOTH_SHADER_PATH) as Shader
		_cloth_material.set_shader_parameter("cloth_uv2", true)
		_cloth_material.set_shader_parameter("detail_strength", CLOTH_DETAIL)
		# La ropa venía con azules y amarillos de pantalla; el resto del mundo es
		# tierra y ocre. Un poco de desaturación los mete en la misma paleta.
		_cloth_material.set_shader_parameter("desaturation", CLOTH_DESATURATION)
		var scales: PackedFloat32Array = LAYER_SCALES.duplicate()
		scales[Layer.FABRIC] = CLOTH_SCALE
		_cloth_material.set_shader_parameter("layer_scale", scales)
	return _cloth_material


## Ropa con el textil del personaje (alcance v4.0): [param textile] es la
## textura que el generador pone como color base del material «pch_cloth».
static func textile_cloth_material(textile: Texture2D) -> ShaderMaterial:
	if textile == null:
		return cloth_material()
	if not _textile_materials.has(textile):
		var material: ShaderMaterial = cloth_material().duplicate() as ShaderMaterial
		material.set_shader_parameter("textile", textile)
		material.set_shader_parameter("use_textile", true)
		_textile_materials[textile] = material
	return _textile_materials[textile]


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
	# El borde de la plaza y los caminos tenía un corte recto visible a poca
	# distancia; un fundido más ancho lo disuelve sin emborronar el camino.
	material.set_shader_parameter("overlay_fade", 5.0)
	# La variación de gran escala usa una lectura muy ampliada del mismo
	# detalle: si es demasiado grande se convierte en manchas.
	material.set_shader_parameter("macro_scale", 0.28)
	material.set_shader_parameter("macro_strength", 0.50)
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
				var textile: Texture2D = (material as BaseMaterial3D).albedo_texture if material is BaseMaterial3D else null
				mesh_instance.set_surface_override_material(surface, textile_cloth_material(textile))
				touched = true
			elif material is BaseMaterial3D and (material.resource_name.ends_with(".body") or material.resource_name == "rb.head"):
				# Piel: algo de brillo suave y luz de borde, que la aleja del
				# aspecto de cera o de barro.
				mesh_instance.set_surface_override_material(surface, _skin(material as BaseMaterial3D))
				touched = true
			elif material is BaseMaterial3D and material.resource_name == "pch.body":
				# Piel Quaternius: la textura es clara; el tinte la lleva al
				# moreno de la sierra sin perder labios, ojos ni detalle.
				mesh_instance.set_surface_override_material(
					surface, _skin(material as BaseMaterial3D, Color(0.72, 0.55, 0.42, 1.0)))
				touched = true
			elif material is BaseMaterial3D and material.resource_name.begins_with("pch.eye"):
				var q_eyes: BaseMaterial3D = (material as BaseMaterial3D).duplicate() as BaseMaterial3D
				q_eyes.roughness = 0.22
				q_eyes.metallic_specular = 0.45
				mesh_instance.set_surface_override_material(surface, q_eyes)
				touched = true
			elif material is BaseMaterial3D and (material.resource_name.begins_with("pch.hair") or material.resource_name.begins_with("MI_Hair")):
				var q_hair: BaseMaterial3D = (material as BaseMaterial3D).duplicate() as BaseMaterial3D
				q_hair.albedo_color = Color(0.20, 0.15, 0.11, 1.0)
				if material.resource_name.begins_with("pch.hair_grey"):
					q_hair.albedo_color = Color(0.62, 0.58, 0.52, 1.0)
				q_hair.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				q_hair.alpha_scissor_threshold = HAIR_ALPHA_SCISSOR
				q_hair.cull_mode = BaseMaterial3D.CULL_DISABLED
				mesh_instance.set_surface_override_material(surface, q_hair)
				touched = true
			elif material is BaseMaterial3D and material.resource_name.ends_with(".low-poly"):
				# Ojos: húmedos, con reflejo; sin él la mirada parece muerta,
				# pero demasiado brillo la vuelve de muñeca.
				var eyes: BaseMaterial3D = (material as BaseMaterial3D).duplicate() as BaseMaterial3D
				eyes.roughness = 0.22
				eyes.metallic_specular = 0.45
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


static func _skin(material: BaseMaterial3D, tint: Color = Color(1.0, 0.94, 0.88, 1.0)) -> BaseMaterial3D:
	var skin: BaseMaterial3D = material.duplicate() as BaseMaterial3D
	skin.albedo_color = tint
	# Piel de museo: mate, sin el brillo de cera que delata a un maniquí, pero
	# con algo más de dispersión y menos borde: la cara deja de verse de yeso
	# bajo el sol fuerte del mediodía andino.
	skin.roughness = 0.72
	skin.metallic_specular = 0.25
	skin.rim_enabled = true
	skin.rim = 0.16
	skin.rim_tint = 0.45
	skin.subsurf_scatter_enabled = true
	skin.subsurf_scatter_strength = 0.12
	skin.subsurf_scatter_skin_mode = true
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
	material.set_shader_parameter("layer_tint", PackedColorArray(LAYER_TINTS))
	# Relieve sin exagerar: a media distancia separa una pared de una calcomanía;
	# de cerca, un exceso convierte la tierra apisonada en grava.
	material.set_shader_parameter("normal_strength", 0.75)
	material.set_shader_parameter("roughness_floor", 0.85)
	return material
