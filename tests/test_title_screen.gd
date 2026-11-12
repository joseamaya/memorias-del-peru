extends RefCounted
## Comprueba la pantalla de título (ADR-0024): textos traducidos, campaña
## válida, foco en Comenzar y un subtítulo que no adelanta la noticia.

const SPOILERS: Array[String] = ["chanca", "heredero", "cusi yupanqui", "amenaza", "pachac"]


func test_title_screen() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/ui/title_screen.tscn") as PackedScene
	if packed == null:
		return false
	var screen: TitleScreen = packed.instantiate() as TitleScreen
	if screen == null:
		return false
	tree.root.add_child(screen)
	var ok: bool = screen.get_campaign() != null
	ok = ok and screen.get_title_text() == "Memorias del Perú"
	var subtitle: String = screen.get_subtitle_text()
	ok = ok and not subtitle.is_empty() and not subtitle.begins_with("PCH_")
	for word: String in SPOILERS:
		ok = ok and not subtitle.to_lower().contains(word)
	var start: Button = screen.get_start_button()
	var quit: Button = screen.get_quit_button()
	ok = ok and start != null and quit != null
	ok = ok and start.text == tr("UI_START") and not start.text.begins_with("UI_")
	ok = ok and quit.text == tr("UI_QUIT") and not quit.text.begins_with("UI_")
	ok = ok and not start.disabled and start.has_focus()
	screen.free()
	return ok
