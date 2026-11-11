extends RefCounted
## Comprueba el validador de modelos con casos buenos y malos construidos en
## memoria, y con un `.glb` real exportado e importado de nuevo con
## GLTFDocument para cubrir el camino de un archivo.

const ROUNDTRIP_PATH: String = "user://test_model_validator_roundtrip.glb"


## Caja de [param size] cuya base queda a [param base_y] del origen.
func _box_model(size: Vector3, base_y: float) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Root"
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0.0, base_y + size.y * 0.5, 0.0)
	root.add_child(mesh_instance)
	return root


func _add_collision(root: Node3D) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	body.add_child(shape)
	root.add_child(body)


func _errors(root: Node3D, file_name: String) -> int:
	var count: int = AssetValidation.validate_model(root, file_name).size()
	root.free()
	return count


func _roundtrip_ok() -> bool:
	var source: Node3D = _box_model(Vector3(0.2, 0.3, 0.2), 0.0)
	var export_doc: GLTFDocument = GLTFDocument.new()
	var export_state: GLTFState = GLTFState.new()
	var ok: bool = export_doc.append_from_scene(source, export_state) == OK
	ok = ok and export_doc.write_to_filesystem(export_state, ROUNDTRIP_PATH) == OK
	source.free()
	if not ok:
		return false
	var import_doc: GLTFDocument = GLTFDocument.new()
	var import_state: GLTFState = GLTFState.new()
	if import_doc.append_from_file(ProjectSettings.globalize_path(ROUNDTRIP_PATH), import_state) != OK:
		return false
	var imported: Node3D = import_doc.generate_scene(import_state) as Node3D
	if imported == null:
		return false
	var errors: PackedStringArray = AssetValidation.validate_model(imported, "pch_quero.glb")
	imported.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ROUNDTRIP_PATH))
	return errors.is_empty()


func test_model_validator() -> bool:
	var ok: bool = true
	# Nombres.
	ok = ok and AssetValidation.validate_file_name("pch_house_a.glb").is_empty()
	ok = ok and not AssetValidation.validate_file_name("House_A.glb").is_empty()
	ok = ok and not AssetValidation.validate_file_name("pch_house_a.blend").is_empty()
	ok = ok and not AssetValidation.validate_file_name("pch-house.glb").is_empty()
	# Objeto correcto y con defectos.
	ok = ok and _errors(_box_model(Vector3(0.2, 0.3, 0.2), 0.0), "pch_quero.glb") == 0
	ok = ok and _errors(_box_model(Vector3(0.2, 0.3, 0.2), 0.5), "pch_quero.glb") > 0
	ok = ok and _errors(_box_model(Vector3(40.0, 3.0, 4.0), 0.0), "pch_quero.glb") > 0
	var scaled: Node3D = _box_model(Vector3(0.2, 0.3, 0.2), 0.0)
	scaled.scale = Vector3(100.0, 100.0, 100.0)
	ok = ok and _errors(scaled, "pch_quero.glb") > 0
	ok = ok and _errors(Node3D.new(), "pch_quero.glb") > 0
	# Casa: exige colisión.
	ok = ok and _errors(_box_model(Vector3(6.0, 3.5, 5.0), 0.0), "pch_house_a.glb") > 0
	var house: Node3D = _box_model(Vector3(6.0, 3.5, 5.0), 0.0)
	_add_collision(house)
	ok = ok and _errors(house, "pch_house_a.glb") == 0
	# Personaje: altura humana y sin colisión propia.
	ok = ok and _errors(_box_model(Vector3(0.5, 1.6, 0.3), 0.0), "pch_npc_weaver.glb") == 0
	ok = ok and _errors(_box_model(Vector3(0.5, 0.16, 0.3), 0.0), "pch_npc_weaver.glb") > 0
	var npc_with_collision: Node3D = _box_model(Vector3(0.5, 1.6, 0.3), 0.0)
	_add_collision(npc_with_collision)
	ok = ok and _errors(npc_with_collision, "pch_npc_weaver.glb") > 0
	# Camino real de un archivo .glb.
	ok = ok and _roundtrip_ok()
	return ok
