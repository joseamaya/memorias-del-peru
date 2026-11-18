extends RefCounted
## Prueba la chaquitaclla del Agricultor: el GLB existe, pasa el validador de
## modelos y conserva las medidas del útil documentado (PCH-037): 1,48 m de
## alto, hoja plana y estribo de unos 22 cm. No comprueba la colocación en la
## escena; de eso se encargan el arco y la captura.

const MODEL_PATH: String = "res://campaigns/01_pachacutec/assets/models/pch_prop_chaquitaclla.glb"
const FILE_NAME: String = "pch_prop_chaquitaclla.glb"
const MIN_HEIGHT: float = 1.30
const MAX_HEIGHT: float = 1.60
const MIN_FOOTREST: float = 0.18


func test_chaquitaclla_model() -> bool:
	var packed: PackedScene = load(MODEL_PATH) as PackedScene
	if packed == null:
		printerr("No carga ", FILE_NAME)
		return false
	var model: Node3D = packed.instantiate() as Node3D
	if model == null:
		printerr(FILE_NAME, ": no instancia")
		return false
	var errors: PackedStringArray = AssetValidation.validate_model(model, FILE_NAME)
	var bounds: AABB = AssetValidation.visual_bounds(model)
	var ok: bool = errors.is_empty()
	if not ok:
		printerr(FILE_NAME, ": ", errors)
	if bounds.size.y < MIN_HEIGHT or bounds.size.y > MAX_HEIGHT:
		printerr(FILE_NAME, ": altura %.2f m fuera de [%.2f, %.2f]" % [
			bounds.size.y, MIN_HEIGHT, MAX_HEIGHT])
		ok = false
	if bounds.size.x < MIN_FOOTREST:
		printerr(FILE_NAME, ": estribo de %.2f m, demasiado estrecho" % bounds.size.x)
		ok = false
	if absf(bounds.position.y) > 0.05:
		printerr(FILE_NAME, ": la base no está en el origen")
		ok = false
	model.free()
	return ok
