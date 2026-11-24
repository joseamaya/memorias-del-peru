extends RefCounted
## Comprueba que los catálogos de diálogos y POI se leen con el cargador de
## recursos, que resuelve los `.tres.remap` de las exportaciones, y que el
## catálogo completo está presente.
##
## Se llaman las mismas entradas que usa el juego (`register_directory` y
## `load_catalog`), no un recuento de nombres de archivo: una regresión del
## cargador dejaría 0 recursos aunque el directorio siguiera lleno.

const DIALOGUE_DIR: String = "res://campaigns/01_pachacutec/data/dialogues"
const POI_DIR: String = "res://campaigns/01_pachacutec/data/pois"
const DIALOGUE_COUNT: int = 11
const POI_COUNT: int = 31


func test_dialogue_catalog_loads_all_graphs() -> bool:
	var presenter: DialoguePresenter = DialoguePresenter.new()
	var loaded: int = presenter.register_directory(DIALOGUE_DIR)
	presenter.free()
	return loaded == DIALOGUE_COUNT


func test_poi_catalog_loads_all_definitions() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var discovery: DiscoveryService = DiscoveryService.new()
	# `load_catalog` consulta `/root/WorldState`; el servicio debe estar en el árbol.
	tree.root.add_child(discovery)
	var loaded: int = discovery.load_catalog(POI_DIR)
	discovery.free()
	return loaded == POI_COUNT
