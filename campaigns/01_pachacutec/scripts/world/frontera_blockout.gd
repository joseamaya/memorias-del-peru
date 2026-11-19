class_name FronteraBlockout
extends Node3D
## Blockout de S6 — Frontera chanca.
##
## Puna, bofedal, tambo abandonado, marcas de piedra, campamento, puesto de
## vigilancia y campo de batalla. Geometría gris; no hay combate ni facciones.

const STONE: Color = Color(0.60, 0.56, 0.50)
const WALL: Color = Color(0.68, 0.62, 0.50)
const WOOD: Color = Color(0.36, 0.28, 0.20)
const WATER: Color = Color(0.28, 0.45, 0.52)
const ASH: Color = Color(0.24, 0.22, 0.20)
const CLOTH: Color = Color(0.55, 0.42, 0.30)

var _region: CampaignRegion = null
var _poi_labels: Array[Label3D] = []


func _ready() -> void:
	_region = get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	if _region == null:
		push_error("FronteraBlockout: falta el terreno regional.")
		return
	_build_bofedal()
	_build_tambo()
	_build_marks()
	_build_camp()
	_build_tower()
	_build_battlefield()


func get_poi_count() -> int:
	return _poi_labels.size()


func get_mesh_count() -> int:
	return find_children("*", "MeshInstance3D", true, false).size()


func get_collision_count() -> int:
	return find_children("*", "StaticBody3D", true, false).size()


func _build_bofedal() -> void:
	for index: int in 3:
		var x: float = -60.0 + float(index) * 22.0
		var z: float = -80.0 + float(index % 2) * 12.0
		var ground: float = _ground(x, z)
		BlockoutKit.add_cylinder(self, 7.0, 0.15, Vector3(x, ground + 0.08, z), WATER)
	_add_label("POI-12 · Bofedal", _label_at(-60.0, -80.0))


func _build_tambo() -> void:
	var center: Vector3 = Vector3(-55.0, 0.0, -25.0)
	var ground: float = _ground(center.x, center.z)
	BlockoutKit.add_box(
		self,
		Vector3(16.0, 1.6, 0.8),
		Vector3(center.x, ground + 0.8, center.z - 5.0),
		WALL,
		true,
		Basis.IDENTITY,
		"Tambo"
	)
	BlockoutKit.add_box(
		self,
		Vector3(16.0, 1.6, 0.8),
		Vector3(center.x, ground + 0.8, center.z + 5.0),
		WALL,
		true,
		Basis.IDENTITY,
		"Tambo"
	)
	BlockoutKit.add_box(
		self,
		Vector3(0.8, 1.6, 10.0),
		Vector3(center.x - 8.0, ground + 0.8, center.z),
		WALL,
		true,
		Basis.IDENTITY,
		"Tambo"
	)
	BlockoutKit.add_box(
		self,
		Vector3(0.8, 1.6, 10.0),
		Vector3(center.x + 8.0, ground + 0.8, center.z - 3.0),
		WALL,
		true,
		Basis.IDENTITY,
		"Tambo"
	)
	_add_label("POI-26 · Tambo abandonado", _label_at(center.x, center.z))


func _build_marks() -> void:
	for index: int in 6:
		var x: float = -10.0 + float(index) * 3.5
		var z: float = 45.0 + float(index % 2) * 2.0
		var ground: float = _ground(x, z)
		BlockoutKit.add_box(
			self,
			Vector3(0.9, 2.5, 0.9),
			Vector3(x, ground + 1.25, z),
			STONE,
			true,
			Basis.IDENTITY,
			"Marca"
		)
	_add_label("POI-27 · Marcas de piedra", _label_at(0.0, 45.0))


func _build_camp() -> void:
	for index: int in 4:
		var x: float = 40.0 + float(index % 2) * 10.0
		var z: float = 25.0 + float(index / 2) * 10.0
		var ground: float = _ground(x, z)
		BlockoutKit.add_box(
			self,
			Vector3(4.0, 1.8, 4.0),
			Vector3(x, ground + 0.9, z),
			CLOTH,
			true,
			Basis(Vector3.UP, PI * 0.25),
			"Tienda"
		)
		BlockoutKit.add_cylinder(self, 0.8, 0.4, Vector3(x + 3.0, ground + 0.2, z + 3.0), ASH)
	for index: int in 6:
		var x: float = 32.0 + float(index) * 4.0
		var ground: float = _ground(x, 20.0)
		BlockoutKit.add_box(
			self,
			Vector3(0.3, 2.2, 0.3),
			Vector3(x, ground + 1.1, 20.0),
			WOOD,
			false,
			Basis.IDENTITY,
			"Empalizada"
		)
	_add_label("POI-28 · Campamento chanca", _label_at(45.0, 30.0))


func _build_tower() -> void:
	var x: float = 75.0
	var z: float = -45.0
	var ground: float = _ground(x, z)
	for offset: Vector2 in [Vector2(-2, -2), Vector2(2, -2), Vector2(-2, 2), Vector2(2, 2)]:
		BlockoutKit.add_box(
			self,
			Vector3(0.35, 4.5, 0.35),
			Vector3(x + offset.x, ground + 2.25, z + offset.y),
			WOOD,
			false,
			Basis.IDENTITY,
			"Puesto"
		)
	BlockoutKit.add_box(
		self,
		Vector3(5.0, 0.4, 5.0),
		Vector3(x, ground + 4.5, z),
		WOOD,
		false,
		Basis.IDENTITY,
		"Puesto"
	)


func _build_battlefield() -> void:
	for index: int in 6:
		var x: float = -20.0 + float(index % 3) * 14.0
		var z: float = -60.0 + float(index / 3) * 12.0
		var ground: float = _ground(x, z)
		BlockoutKit.add_box(
			self,
			Vector3(5.0, 0.5, 4.0),
			Vector3(x, ground + 0.25, z),
			ASH,
			false,
			Basis.IDENTITY,
			"Campo"
		)
	for index: int in 4:
		var x: float = -30.0 + float(index) * 18.0
		var ground: float = _ground(x, -40.0)
		BlockoutKit.add_box(
			self,
			Vector3(0.8, 2.0, 0.8),
			Vector3(x, ground + 1.0, -40.0),
			STONE,
			true,
			Basis.IDENTITY,
			"Enterramiento"
		)
	_add_label("POI-29 · Campo de batalla", _label_at(-5.0, -55.0))


func _add_label(text: String, label_position: Vector3) -> void:
	_poi_labels.append(BlockoutKit.add_label(self, text, label_position))


func _label_at(x: float, z: float) -> Vector3:
	return Vector3(x, _ground(x, z) + 4.0, z)


func _ground(x: float, z: float) -> float:
	if _region == null:
		return global_position.y
	return _region.height_at(global_position.x + x, global_position.z + z)
