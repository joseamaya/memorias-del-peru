class_name PasoBlockout
extends Node3D
## Blockout de S5 — Paso.
##
## Zigzag, refugio de pirca, mirador, parapeto, altar de altura y nieve
## estacional de marcador. Geometría gris, sin clima ni combate.

const STONE: Color = Color(0.62, 0.58, 0.52)
const PATH: Color = Color(0.44, 0.38, 0.28)
const WATER: Color = Color(0.30, 0.48, 0.58)
const SNOW: Color = Color(0.86, 0.88, 0.90)

var _region: CampaignRegion = null
var _poi_labels: Array[Label3D] = []


func _ready() -> void:
	_region = get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	if _region == null:
		push_error("PasoBlockout: falta el terreno regional.")
		return
	_build_path()
	_build_refuge()
	_build_mirador()
	_build_altar()
	_build_snow()


func get_poi_count() -> int:
	return _poi_labels.size()


func get_mesh_count() -> int:
	return find_children("*", "MeshInstance3D", true, false).size()


func get_collision_count() -> int:
	return find_children("*", "StaticBody3D", true, false).size()


func _build_path() -> void:
	var points: PackedVector3Array = PackedVector3Array(
		[
			Vector3(-140.0, 0.0, -80.0),
			Vector3(-90.0, 0.0, -45.0),
			Vector3(-40.0, 0.0, -70.0),
			Vector3(10.0, 0.0, -30.0),
			Vector3(50.0, 0.0, 10.0),
			Vector3(95.0, 0.0, 65.0),
		]
	)
	var mesh: MeshInstance3D = BlockoutKit.add_ribbon(self, points, _ground, 2.6, PATH, 0.10)
	mesh.name = "Zigzag"


func _build_refuge() -> void:
	var x: float = 5.0
	var z: float = 5.0
	var ground: float = _ground(x, z)
	BlockoutKit.add_box(
		self,
		Vector3(6.0, 1.3, 5.0),
		Vector3(x, ground + 0.65, z - 2.5),
		STONE,
		true,
		Basis.IDENTITY,
		"Pirca"
	)
	BlockoutKit.add_box(
		self,
		Vector3(0.8, 1.3, 5.0),
		Vector3(x - 3.0, ground + 0.65, z),
		STONE,
		true,
		Basis.IDENTITY,
		"Pirca"
	)
	BlockoutKit.add_box(
		self,
		Vector3(0.8, 1.3, 5.0),
		Vector3(x + 3.0, ground + 0.65, z),
		STONE,
		true,
		Basis.IDENTITY,
		"Pirca"
	)
	BlockoutKit.add_box(
		self,
		Vector3(6.8, 0.4, 6.0),
		Vector3(x, ground + 2.0, z),
		PATH,
		false,
		Basis.IDENTITY,
		"Techo"
	)
	_add_label("POI-24 · Refugio de pirca", _label_at(x, z))


func _build_mirador() -> void:
	var x: float = 85.0
	var z: float = 70.0
	var ground: float = _ground(x, z)
	BlockoutKit.add_box(
		self,
		Vector3(10.0, 0.6, 8.0),
		Vector3(x, ground + 0.3, z),
		STONE,
		false,
		Basis.IDENTITY,
		"Mirador"
	)
	BlockoutKit.add_box(
		self,
		Vector3(10.0, 1.1, 0.6),
		Vector3(x, ground + 1.1, z - 3.7),
		STONE,
		true,
		Basis.IDENTITY,
		"Parapeto"
	)
	_add_label("POI-23 · Mirador del paso", _label_at(x, z))


func _build_altar() -> void:
	var x: float = -80.0
	var z: float = 65.0
	var ground: float = _ground(x, z)
	BlockoutKit.add_box(
		self,
		Vector3(4.5, 0.5, 4.5),
		Vector3(x, ground + 0.25, z),
		STONE,
		false,
		Basis.IDENTITY,
		"Altar"
	)
	BlockoutKit.add_box(
		self,
		Vector3(1.2, 3.0, 1.2),
		Vector3(x, ground + 2.0, z),
		SNOW,
		true,
		Basis.IDENTITY,
		"Monolito"
	)
	_add_label("POI-30 · Altar de altura", _label_at(x, z))


func _build_snow() -> void:
	for index: int in 3:
		var x: float = -40.0 + float(index) * 35.0
		var z: float = 20.0 - float(index) * 25.0
		BlockoutKit.add_terrain_disk(
			self, 7.0, 0.08, SNOW, _ground, 48, 6, Vector2(x, z), "Nieve"
		)


func _add_label(text: String, label_position: Vector3) -> void:
	_poi_labels.append(BlockoutKit.add_label(self, text, label_position))


func _label_at(x: float, z: float) -> Vector3:
	return Vector3(x, _ground(x, z) + 4.0, z)


func _ground(x: float, z: float) -> float:
	if _region == null:
		return global_position.y
	return _region.height_at(global_position.x + x, global_position.z + z)
