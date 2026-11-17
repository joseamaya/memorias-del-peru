extends RefCounted
## Pruebas del set híbrido Rocketbox (cuerpo y ropa Quaternius + cabeza
## realista). Comprueban que el set Quaternius sigue intacto, que el catálogo
## no cambia el valor por defecto y que el piloto de Sisa conserva el rig y la
## ropa Q con una sola malla de cabeza rígida al hueso Head.

const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const HYBRID: String = "pch_npc_sisa_rb.glb"
const QUATERNIUS: String = "pch_npc_sisa_q.glb"
const CLIPS: Array[StringName] = [&"idle", &"walk", &"run", &"talk", &"attack", &"hit", &"death"]


func test_rocketbox_catalog() -> bool:
	var ok: bool = true
	if CharacterCatalog.ROCKETBOX_MODELS.get("Habitante3") != HYBRID:
		printerr("El catálogo híbrido no apunta a Sisa")
		ok = false
	if CharacterCatalog.QUATERNIUS_MODELS.get("Habitante3") != QUATERNIUS:
		printerr("El catálogo Quaternius cambió de modelo")
		ok = false
	if not CharacterCatalog.is_rocketbox_file(HYBRID):
		printerr("El nombre híbrido no se reconoce")
		ok = false
	if CharacterCatalog.is_rocketbox_file(QUATERNIUS):
		printerr("Un GLB Quaternius se confunde con el híbrido")
		ok = false
	if not CharacterCatalog.is_quaternius_file(QUATERNIUS):
		printerr("El GLB Quaternius dejó de reconocerse")
		ok = false
	return ok


func test_rocketbox_assets() -> bool:
	var packed: PackedScene = load(MODEL_DIR + HYBRID) as PackedScene
	if packed == null:
		printerr("No carga ", HYBRID)
		return false
	var model: Node3D = packed.instantiate() as Node3D
	var ok: bool = true
	var errors: PackedStringArray = AssetValidation.validate_model(model, HYBRID)
	if not errors.is_empty():
		printerr(HYBRID, ": ", errors)
		ok = false
	var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false) as Skeleton3D
	if skeleton == null or skeleton.get_bone_count() != 65:
		printerr("Esqueleto híbrido inesperado")
		ok = false
	elif skeleton.find_bone("Head") < 0 or skeleton.find_bone("hand_r") < 0:
		printerr("Faltan Head o hand_r en el híbrido")
		ok = false
	if not QuaterniusClips.is_quaternius(model):
		printerr("El híbrido no conserva el rig Quaternius")
		ok = false
	var player: AnimationPlayer = QuaterniusClips.ensure_player(model)
	for clip: StringName in CLIPS:
		if player == null or not player.has_animation(clip):
			printerr("Falta el clip ", clip)
			ok = false
	var head: MeshInstance3D = model.find_child("HeadRB", true, false) as MeshInstance3D
	if head == null:
		printerr("Falta la malla HeadRB")
		ok = false
	elif head.skin == null or head.skin.get_bind_count() < 1:
		printerr("La cabeza no está ligada al esqueleto")
		ok = false
	elif skeleton != null and head.skin.get_bind_count() != skeleton.get_bone_count():
		printerr("La piel de la cabeza no cubre el esqueleto Q")
		ok = false
	var body: MeshInstance3D = model.find_child("Body", true, false) as MeshInstance3D
	var clothes: MeshInstance3D = model.find_child("Clothes", true, false) as MeshInstance3D
	if body == null or clothes == null:
		printerr("Faltan el cuerpo o la ropa Quaternius")
		ok = false
	if model.find_child("Hair", true, false) != null:
		printerr("El pelo Quaternius no se retiró")
		ok = false
	if model.find_child("Eyes", true, false) != null:
		printerr("Los ojos Quaternius no se retiraron")
		ok = false
	if head != null and head.mesh != null:
		var material: Material = head.mesh.surface_get_material(0)
		if material == null or material.resource_name != "rb.head":
			printerr("La cabeza no usa el material Rocketbox")
			ok = false
	if body != null and body.mesh != null:
		var material: Material = body.mesh.surface_get_material(0)
		if material == null or material.resource_name != "pch.body_sisa":
			printerr("El cuerpo híbrido no conserva el material Q")
			ok = false
	model.free()
	return ok


func test_rocketbox_keeps_quaternius() -> bool:
	# El híbrido no debe haber reemplazado el GLB Quaternius.
	var packed: PackedScene = load(MODEL_DIR + QUATERNIUS) as PackedScene
	if packed == null:
		return false
	var model: Node3D = packed.instantiate() as Node3D
	var ok: bool = model.find_child("Hair", true, false) != null
	ok = ok and model.find_child("Eyes", true, false) != null
	ok = ok and model.find_child("Body", true, false) != null
	ok = ok and model.find_child("HeadRB", true, false) == null
	model.free()
	return ok
