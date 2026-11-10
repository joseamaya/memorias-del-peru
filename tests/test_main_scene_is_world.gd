extends RefCounted
## Comprueba que la escena principal es el mundo base.


func test_main_scene_is_world() -> bool:
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	return main_scene == "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
