extends RefCounted
## Valida cada modelo de la carpeta de la campaña con las reglas de §7 del
## alcance. Mientras no haya modelos la prueba pasa sin comprobar nada; en
## cuanto se añade un `.glb`, queda cubierto. Prohíbe los `.blend` (§7: no se
## importan) y los `.glb` sin importar.

const MODEL_DIRS: Array[String] = ["res://campaigns/01_pachacutec/assets/models/"]


func test_model_files_valid() -> bool:
	var ok: bool = true
	for directory: String in MODEL_DIRS:
		if not DirAccess.dir_exists_absolute(directory):
			continue
		for file_name: String in DirAccess.get_files_at(directory):
			if file_name.ends_with(".import"):
				continue
			if file_name.ends_with(".blend") or file_name.ends_with(".blend1"):
				printerr("Modelo no permitido (se exporta a .glb): ", directory + file_name)
				ok = false
				continue
			if not file_name.ends_with(".glb"):
				continue
			var packed: PackedScene = load(directory + file_name) as PackedScene
			if packed == null:
				printerr("No se pudo cargar (¿falta importar?): ", directory + file_name)
				ok = false
				continue
			var instance: Node3D = packed.instantiate() as Node3D
			if instance == null:
				printerr("La raíz no es Node3D: ", directory + file_name)
				ok = false
				continue
			var errors: PackedStringArray = AssetValidation.validate_model(instance, file_name)
			instance.free()
			for message: String in errors:
				printerr(message)
			ok = ok and errors.is_empty()
	return ok
