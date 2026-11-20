class_name QuebradaBlockout
extends Node3D
## Blockout de S4 — Quebrada alta.
##
## Terrazas altas, queñua, salto de agua, cueva, cantera y refugio de pastores.
## Geometría gris de blockout; los recursos no son todavía interactivos.

const STONE: Color = Color(0.60, 0.56, 0.48)
const SOIL: Color = Color(0.38, 0.30, 0.20)
const WATER: Color = Color(0.30, 0.48, 0.58)
const GRASS: Color = Color(0.42, 0.48, 0.30)
const DARK: Color = Color(0.10, 0.09, 0.08)
const WALL: Color = Color(0.72, 0.66, 0.54)
const ROOF: Color = Color(0.42, 0.34, 0.25)

var _region: CampaignRegion = null
var _poi_labels: Array[Label3D] = []


func _ready() -> void:
	_region = get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	if _region == null:
		push_error("QuebradaBlockout: falta el terreno regional.")
		return
	_build_terraces()
	_build_quenua()
	_build_waterfall()
	_build_cave()
	_build_quarry()
	_build_refuge()


func get_poi_count() -> int:
	return _poi_labels.size()


func get_mesh_count() -> int:
	return find_children("*", "MeshInstance3D", true, false).size()


func get_collision_count() -> int:
	return find_children("*", "StaticBody3D", true, false).size()


func _build_terraces() -> void:
	for index: int in 5:
		var x: float = -90.0 + float(index) * 12.0
		var z: float = 55.0 + float(index % 2) * 8.0
		var ground: float = _ground(x, z)
		var footprint: Vector3 = Vector3(10.0, 0.0, 5.0)
		var low: float = BlockoutKit.min_ground(_ground, x, z, footprint)
		# La terraza baja hasta el punto más bajo de su huella: si no, el
		# borde cuesta abajo queda como una losa flotante.
		var height: float = maxf(0.7, ground - low + 0.7)
		BlockoutKit.add_box(
			self,
			Vector3(10.0, height, 5.0),
			Vector3(x, low + height * 0.5, z),
			SOIL,
			true,
			Basis.IDENTITY,
			"Terraza"
		)
	_add_label("POI-10 · Terrazas altas de papa", _label_at(-66.0, 70.0))


func _build_quenua() -> void:
	for index: int in 8:
		var angle: float = float(index) * 0.9
		var radius: float = 18.0 + float(index % 3) * 6.0
		var x: float = -20.0 + cos(angle) * radius
		var z: float = -25.0 + sin(angle) * radius
		var ground: float = _ground(x, z)
		BlockoutKit.add_cylinder(self, 0.28, 3.2, Vector3(x, ground + 1.6, z), DARK)
		BlockoutKit.add_sphere(self, 1.9, Vector3(x, ground + 3.8, z), GRASS)
	_add_label("POI-11 · Bosque de queñua", _label_at(-20.0, -25.0))


func _build_waterfall() -> void:
	var x: float = 10.0
	var z: float = -70.0
	var ground: float = _ground(x, z)
	BlockoutKit.add_box(
		self,
		Vector3(3.0, 9.0, 0.5),
		Vector3(x, ground + 4.5, z),
		WATER,
		false,
		Basis.IDENTITY,
		"Salto"
	)
	BlockoutKit.add_terrain_disk(
		self, 5.0, 0.2, WATER, _ground, 48, 6, Vector2(x, z + 9.0), "Poza"
	)
	_add_label("POI-13 · Salto de agua", _label_at(x, z))


func _build_cave() -> void:
	var x: float = -115.0
	var z: float = -55.0
	var ground: float = _ground(x, z)
	BlockoutKit.add_box(
		self,
		Vector3(9.0, 5.0, 10.0),
		Vector3(x, ground + 2.5, z),
		DARK,
		false,
		Basis.IDENTITY,
		"Cueva"
	)
	BlockoutKit.add_box(
		self,
		Vector3(11.0, 5.6, 1.0),
		Vector3(x, ground + 2.8, z - 5.5),
		STONE,
		true,
		Basis.IDENTITY,
		"CuevaMarco"
	)
	_add_label("POI-25 · Cueva con ofrendas", _label_at(x, z))


func _build_quarry() -> void:
	for index: int in 6:
		var x: float = 70.0 + float(index % 3) * 8.0
		var z: float = 35.0 + float(index / 3) * 9.0
		var ground: float = _ground(x, z)
		var size: float = 2.0 + float(index % 3)
		BlockoutKit.add_box(
			self,
			Vector3(size, size * 0.8, size * 1.2),
			Vector3(x, ground + size * 0.4, z),
			STONE,
			true,
			Basis.IDENTITY,
			"Cantera"
		)
	_add_label("POI-14 · Cantera de piedra", _label_at(70.0, 35.0))


func _build_refuge() -> void:
	var x: float = 20.0
	var z: float = 55.0
	var ground: float = _ground(x, z)
	BlockoutKit.add_box(
		self,
		Vector3(4.5, 2.2, 3.5),
		Vector3(x, ground + 1.1, z),
		WALL,
		true,
		Basis.IDENTITY,
		"Refugio"
	)
	BlockoutKit.add_box(
		self,
		Vector3(5.0, 0.3, 4.0),
		Vector3(x, ground + 2.35, z),
		ROOF,
		false,
		Basis.IDENTITY,
		"Techo"
	)


func _add_label(text: String, label_position: Vector3) -> void:
	_poi_labels.append(BlockoutKit.add_label(self, text, label_position))


func _label_at(x: float, z: float) -> Vector3:
	return Vector3(x, _ground(x, z) + 4.0, z)


func _ground(x: float, z: float) -> float:
	if _region == null:
		return global_position.y
	return _region.height_at(global_position.x + x, global_position.z + z)
