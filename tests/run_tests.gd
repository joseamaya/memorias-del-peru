extends SceneTree
## Ejecutor mínimo de pruebas automatizadas.
##
## Carga cada `tests/test_*.gd`, ejecuta sus métodos `test_*` y termina con
## código 0 si todo pasa o 1 si algo falla.

const TESTS_DIR: String = "res://tests"


func _initialize() -> void:
	_run_tests.call_deferred()


func _run_tests() -> void:
	var failures: int = 0
	var files: PackedStringArray = DirAccess.get_files_at(TESTS_DIR)
	for file_name: String in files:
		if not file_name.begins_with("test_") or not file_name.ends_with(".gd"):
			continue
		var test_script: GDScript = load(TESTS_DIR + "/" + file_name) as GDScript
		if test_script == null or not test_script.can_instantiate():
			printerr("No se pudo cargar ", file_name)
			failures += 1
			continue
		var instance: Object = test_script.new()
		if instance == null:
			printerr("No se pudo instanciar ", file_name)
			failures += 1
			continue
		var methods: Array[Dictionary] = instance.get_method_list()
		for method: Dictionary in methods:
			var method_name: String = str(method["name"])
			if not method_name.begins_with("test_"):
				continue
			var callable: Callable = Callable(instance, method_name)
			if callable.call() == true:
				print("OK   ", file_name, "::", method_name)
			else:
				printerr("FALLO ", file_name, "::", method_name)
				failures += 1
	print("Pruebas finalizadas: ", failures, " fallo(s)")
	var audio: AudioManagerService = root.get_node_or_null("AudioManager") as AudioManagerService
	if audio != null:
		audio.stop_all()
	quit(1 if failures > 0 else 0)
