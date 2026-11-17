class_name QuaterniusMaterials
extends RefCounted
## Materiales de los cuerpos Quaternius del prototipo (piel, cejas, pelo y
## ojos). Viven aparte de `SurfaceMaterials` para que la ciudad y el terreno no
## carguen con la lógica de personajes.
##
## Los GLB no embeben texturas: este archivo carga una sola vez las albedo,
## normal y rugosidad de `shared_assets/characters/quaternius/` y comparte el
## material entre modelos. Las texturas de rostro por personaje salen de
## `tools/build_face_textures.py` (UBC, CC0).

const BASE: String = "res://shared_assets/characters/quaternius/base/"
const FACES: String = "res://shared_assets/characters/quaternius/faces/"
const HAIR_ALPHA_SCISSOR: float = 0.4
## Texturas de rostro por personaje. El tono de piel va horneado y la cara
## lleva labios, ojeras y líneas de edad.
const FACE_SET: Dictionary[String, Dictionary] = {
	"pch.body_sisa": {"texture": "pch_face_sisa.png", "male": false},
	"pch.body_curaca": {"texture": "pch_face_curaca.png", "male": true},
	"pch.body_mensajero": {"texture": "pch_face_mensajero.png", "male": true},
	"pch.body_chanca": {"texture": "pch_face_chanca.png", "male": true},
	"pch.body_anciana": {"texture": "pch_face_anciana.png", "male": false},
	"pch.body_joven": {"texture": "pch_face_joven.png", "male": true},
	"pch.body_madre": {"texture": "pch_face_madre.png", "male": false},
	"pch.body_hermano": {"texture": "pch_face_hermano.png", "male": true},
	"pch.body_puma": {"texture": "pch_face_puma.png", "male": true},
	"pch.body_anca": {"texture": "pch_face_anca.png", "male": false},
}

static var _cache: Dictionary[String, Material] = {}


## Material de [param name], o `null` si el nombre no es de Quaternius.
static func get_material(name: String) -> Material:
	if _cache.has(name):
		return _cache[name]
	var material: StandardMaterial3D = null
	if name.begins_with("pch.body_"):
		var albedo: Texture2D = null
		var normal: Texture2D = null
		var roughness: Texture2D = null
		var tint: Color = Color.WHITE
		var male: bool = true
		var own_face: bool = FACE_SET.has(name)
		if own_face:
			# Textura propia: el tono y los rasgos ya están horneados.
			var face: Dictionary = FACE_SET[name]
			male = face["male"] == true
			albedo = load(FACES + str(face["texture"])) as Texture2D
			normal = load(FACES + ("T_Superhero_Male_Normal" if male
				else "T_Superhero_Female_Normal") + ".png") as Texture2D
			roughness = load(FACES + ("T_Superhero_Male_Roughness" if male
				else "T_Superhero_Female_Roughness") + ".png") as Texture2D
		else:
			var parts: PackedStringArray = name.trim_prefix("pch.body_").split("_")
			if parts.size() < 2:
				return null
			var tone: String = parts[0]
			male = parts[1] == "m"
			var base_name: String = ("T_Superhero_Male_Dark" if male
				else "T_Superhero_Female_Dark_BaseColor")
			albedo = load(BASE + base_name + ".png") as Texture2D
			normal = load(BASE + ("T_Superhero_Male_Normal" if male
				else "T_Superhero_Female_Normal") + ".png") as Texture2D
			tint = Color(0.72, 0.55, 0.42, 1.0)
			if tone == "light":
				tint = Color(0.80, 0.62, 0.48, 1.0)
			elif tone == "dark":
				tint = Color(0.62, 0.46, 0.35, 1.0)
		if albedo == null:
			return null
		material = StandardMaterial3D.new()
		material.albedo_texture = albedo
		material.albedo_color = tint
		material.normal_enabled = normal != null
		material.normal_texture = normal
		material.roughness = 1.0 if roughness != null else 0.72
		material.roughness_texture = roughness
		material.metallic_specular = 0.15 if own_face else 0.25
		material.rim_enabled = true
		material.rim = 0.10 if own_face else 0.16
		material.rim_tint = 0.45
		material.subsurf_scatter_enabled = true
		material.subsurf_scatter_strength = 0.12
		material.subsurf_scatter_skin_mode = true
	elif name.begins_with("pch.brow_"):
		var parts: PackedStringArray = name.trim_prefix("pch.brow_").split("_")
		if parts.size() < 2:
			return null
		var grey: bool = parts[0] == "grey"
		var male: bool = parts[1] == "m"
		var hair_name: String = "T_Hair_1" if male else "T_Hair_2"
		var albedo: Texture2D = load(BASE + hair_name + "_BaseColor.png") as Texture2D
		var normal: Texture2D = load(BASE + hair_name + "_Normal.png") as Texture2D
		if albedo == null:
			return null
		material = StandardMaterial3D.new()
		material.albedo_texture = albedo
		material.albedo_color = Color(0.86, 0.82, 0.76, 1.0) if grey else Color(0.34, 0.25, 0.18, 1.0)
		material.normal_enabled = normal != null
		material.normal_texture = normal
		material.roughness = 0.90
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.alpha_scissor_threshold = HAIR_ALPHA_SCISSOR
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	elif name.begins_with("pch.hair_"):
		var parts: PackedStringArray = name.trim_prefix("pch.hair_").split("_")
		if parts.size() < 2:
			return null
		var grey: bool = parts[0] == "grey"
		var male: bool = parts[1] == "m"
		var hair_name: String = "T_Hair_1" if male else "T_Hair_2"
		var albedo: Texture2D = load(BASE + hair_name + "_BaseColor.png") as Texture2D
		var normal: Texture2D = load(BASE + hair_name + "_Normal.png") as Texture2D
		if albedo == null:
			return null
		material = StandardMaterial3D.new()
		material.albedo_texture = albedo
		material.albedo_color = Color(0.82, 0.78, 0.72, 1.0) if grey else Color(0.20, 0.15, 0.11, 1.0)
		material.normal_enabled = normal != null
		material.normal_texture = normal
		material.roughness = 0.82
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.alpha_scissor_threshold = HAIR_ALPHA_SCISSOR
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	elif name.begins_with("pch.eye"):
		var albedo: Texture2D = load(BASE + "T_Eye_Brown.png") as Texture2D
		var normal: Texture2D = load(BASE + "T_Eye_Normal.png") as Texture2D
		if albedo == null:
			return null
		material = StandardMaterial3D.new()
		material.albedo_texture = albedo
		material.normal_enabled = normal != null
		material.normal_texture = normal
		material.roughness = 0.22
		material.metallic_specular = 0.45
	if material == null:
		return null
	_cache[name] = material
	return material
