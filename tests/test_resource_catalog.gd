extends RefCounted
## Comprueba que los catálogos de diálogos y POI se leen con el cargador de
## recursos, que resuelve los `.tres.remap` de las exportaciones.

const DIALOGUE_DIR: String = "res://campaigns/01_pachacutec/data/dialogues"
const POI_DIR: String = "res://campaigns/01_pachacutec/data/pois"


func _count_resources(files: PackedStringArray) -> int:
	var count: int = 0
	for file_name: String in files:
		if file_name.ends_with(".tres"):
			count += 1
	return count


func test_dialogue_catalog_uses_resource_loader() -> bool:
	var files: PackedStringArray = ResourceLoader.list_directory(DIALOGUE_DIR)
	var presenter: DialoguePresenter = DialoguePresenter.new()
	var loaded: int = presenter.register_directory(DIALOGUE_DIR)
	presenter.free()
	return _count_resources(files) >= 6 and loaded >= 6


func test_poi_catalog_uses_resource_loader() -> bool:
	var files: PackedStringArray = ResourceLoader.list_directory(POI_DIR)
	return _count_resources(files) >= 20
