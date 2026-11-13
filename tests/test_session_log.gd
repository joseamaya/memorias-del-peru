extends RefCounted
## Comprueba el registro de sesiones de prueba (alcance §9.2 y §9.6).

const TEST_DIR: String = "user://sesiones_test"


func test_session_code_validation() -> bool:
	return (
		SessionLogService.is_valid_code("PIL-2")
		and SessionLogService.is_valid_code("P1_prueba")
		and not SessionLogService.is_valid_code("")
		and not SessionLogService.is_valid_code("PIL 2")
		and not SessionLogService.is_valid_code("../fuera")
		and not SessionLogService.is_valid_code("PIL/2")
		and not SessionLogService.is_valid_code("P".repeat(25))
	)


func test_session_log_writes_marks() -> bool:
	var service: SessionLogService = SessionLogService.new()
	if not service.start("PIL-TEST", TEST_DIR):
		service.free()
		return false
	if service.start("OTRA", TEST_DIR):
		# No se puede abrir una segunda sesión mientras la primera sigue activa.
		service.free()
		return false
	service.mark(&"intro_card", "1")
	service.mark(&"control_taken")
	service.mark(&"pututu", "jugador")
	service.finish("prueba")
	var path: String = service.get_log_path()
	var content: String = _read(path)
	var still_active: bool = service.is_active()
	service.free()
	_cleanup(path)
	if still_active or content.is_empty():
		return false
	var card_at: int = content.find("\tintro_card\t1")
	var end_at: int = content.find("\tsession_end\tprueba")
	return (
		content.contains("# Código: PIL-TEST")
		and content.contains("# Formato: +MM:SS.mmm")
		and card_at >= 0
		and content.contains("\tcontrol_taken")
		and content.contains("\tpututu\tjugador")
		and end_at > card_at
		and content.begins_with("# Sesión de prueba")
	)


func test_session_inactive_writes_nothing() -> bool:
	var service: SessionLogService = SessionLogService.new()
	service.mark(&"control_taken")
	var active: bool = service.is_active()
	service.free()
	var path: String = ProjectSettings.globalize_path(TEST_DIR.path_join("SIN-SESION.log"))
	return not active and not FileAccess.file_exists(path)


func _read(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var directory: String = ProjectSettings.globalize_path(TEST_DIR)
	if DirAccess.dir_exists_absolute(directory):
		DirAccess.remove_absolute(directory)
