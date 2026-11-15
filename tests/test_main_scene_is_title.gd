extends RefCounted
## Comprueba el punto de entrada: la escena principal es la pantalla de título
## de `core/`. La campaña se conectará cuando su escena de entrada exista.

const TITLE_SCENE: String = "res://core/ui/title_screen.tscn"


func test_main_scene_is_title() -> bool:
	var main_scene: String = str(ProjectSettings.get_setting("application/run/main_scene"))
	return main_scene == TITLE_SCENE
