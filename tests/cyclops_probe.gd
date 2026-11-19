extends SceneTree
## Comprueba que un bloque de Cyclops se convierte en malla y colisión.


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var data: ConvexBlockData = _cube_data()
	var block: CyclopsBlock = CyclopsBlock.new()
	block.block_data = data
	root.add_child(block)
	for _i: int in 3:
		await process_frame
	var mesh: ArrayMesh = block.mesh_instance.mesh as ArrayMesh
	var ok: bool = mesh != null and mesh.get_surface_count() > 0
	ok = ok and block.collision_shape != null and block.collision_shape.shape != null
	block.free()
	await process_frame
	if ok:
		print("CYCLOPS_OK surfaces=", mesh.get_surface_count())
	else:
		printerr("CYCLOPS_FAIL")
	quit(0 if ok else 1)


func _cube_data() -> ConvexBlockData:
	var data: ConvexBlockData = ConvexBlockData.new()
	data.vertex_points = PackedVector3Array(
		[
			Vector3(-1, -1, -1),
			Vector3(1, -1, -1),
			Vector3(1, 1, -1),
			Vector3(-1, 1, -1),
			Vector3(-1, -1, 1),
			Vector3(1, -1, 1),
			Vector3(1, 1, 1),
			Vector3(-1, 1, 1),
		]
	)
	data.vertex_selected = PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
	data.edge_selected = PackedByteArray()
	data.face_material_indices = PackedInt32Array([0, 0, 0, 0, 0, 0])
	data.face_uv_transform = []
	for _i: int in 6:
		data.face_uv_transform.append(Transform2D.IDENTITY)
	data.face_visible = PackedByteArray([1, 1, 1, 1, 1, 1])
	data.face_color = PackedColorArray(
		[Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]
	)
	data.face_selected = PackedByteArray([0, 0, 0, 0, 0, 0])
	data.edge_vertex_indices = PackedInt32Array()
	data.edge_face_indices = PackedInt32Array()
	data.face_vertex_count = PackedInt32Array([4, 4, 4, 4, 4, 4])
	data.face_vertex_indices = PackedInt32Array(
		[0, 3, 2, 1, 4, 5, 6, 7, 0, 4, 7, 3, 1, 2, 6, 5, 0, 1, 5, 4, 3, 7, 6, 2]
	)
	var normals: PackedVector3Array = PackedVector3Array()
	for _i: int in 4:
		normals.append(Vector3(0, 0, -1))
	for _i: int in 4:
		normals.append(Vector3(0, 0, 1))
	for _i: int in 4:
		normals.append(Vector3(-1, 0, 0))
	for _i: int in 4:
		normals.append(Vector3(1, 0, 0))
	for _i: int in 4:
		normals.append(Vector3(0, -1, 0))
	for _i: int in 4:
		normals.append(Vector3(0, 1, 0))
	data.face_vertex_normal = normals
	return data
