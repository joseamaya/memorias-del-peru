extends RefCounted
## Comprueba que Core no referencia rutas, clases ni recursos de campaigns/.


func test_core_has_no_campaign_references() -> bool:
	return _scan_dir("res://core")


func _scan_dir(path: String) -> bool:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return false
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".gd") and not file_name.ends_with(".tscn") and not file_name.ends_with(".tres"):
			continue
		var text: String = FileAccess.get_file_as_string(path.path_join(file_name))
		if text.contains("res://campaigns/") or text.contains("campaigns/"):
			printerr("Core referencia campaña en ", path.path_join(file_name))
			return false
	for directory: String in dir.get_directories():
		if not _scan_dir(path.path_join(directory)):
			return false
	return true
