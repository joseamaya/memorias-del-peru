extends RefCounted
## Comprueba el widget de subtítulos del HUD (ADR-0006).


func test_subtitle_widget() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/ui/hud.tscn") as PackedScene
	if packed == null:
		return false
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	if hud == null:
		return false
	tree.root.add_child(hud)
	var label: Label = hud.get_node_or_null("SubtitleLabel") as Label
	if label == null:
		hud.free()
		return false
	var ok: bool = true
	# Duración: al menos la pedida, el mínimo y el tiempo de lectura (ADR-0012).
	var long_text: String = "¡Los chancas marchan sobre el Cusco! El inca y su heredero han salido de la ciudad."
	ok = ok and is_equal_approx(PlayerHud.reading_seconds("Hola", 0.0), PlayerHud.MIN_SUBTITLE_SECONDS)
	ok = ok and is_equal_approx(PlayerHud.reading_seconds("Hola", 9.0), 9.0)
	ok = ok and PlayerHud.reading_seconds(long_text, 6.0) > 6.0
	# Uno a la vista; el siguiente espera su turno en lugar de pisarlo.
	hud.show_subtitle("Los chancas avanzan", 2.0)
	ok = ok and label.visible and label.text == "Los chancas avanzan"
	hud.show_subtitle("Otra frase", 2.0)
	hud.show_subtitle("Otra frase", 2.0)
	ok = ok and label.text == "Los chancas avanzan" and hud.queued_subtitles() == 1
	var first: float = PlayerHud.reading_seconds("Los chancas avanzan", 2.0)
	hud.advance_subtitle(first - 0.1)
	ok = ok and label.visible and label.text == "Los chancas avanzan"
	hud.advance_subtitle(0.2)
	ok = ok and not label.visible
	hud.advance_subtitle(PlayerHud.SUBTITLE_GAP + 0.01)
	ok = ok and label.visible and label.text == "Otra frase" and hud.queued_subtitles() == 0
	hud.advance_subtitle(PlayerHud.reading_seconds("Otra frase", 2.0) + 0.1)
	ok = ok and not label.visible and not hud.is_showing_subtitle()
	# La cola tiene tope y clear_subtitle() la vacía.
	for index: int in range(PlayerHud.QUEUE_LIMIT + 3):
		hud.show_subtitle("Frase %d" % index, 1.0)
	ok = ok and hud.queued_subtitles() == PlayerHud.QUEUE_LIMIT
	hud.clear_subtitle()
	ok = ok and not label.visible and label.text.is_empty() and hud.queued_subtitles() == 0
	# Rótulo de lugar: aparece con fundido y se oculta al terminar.
	var title: Label = hud.get_node_or_null("TitleLabel") as Label
	hud.show_title("Una llacta", 4.0)
	hud.advance_title(2.0)
	ok = ok and title != null and title.visible and title.modulate.a > 0.9
	hud.advance_title(2.1)
	ok = ok and not title.visible
	hud.free()
	return ok


func test_hud_shows_opening() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var label: Label = world.get_node_or_null("UILayer/HUD/SubtitleLabel") as Label
	if label == null:
		world.free()
		return false
	var text: String = label.text
	var ok: bool = label.visible and not text.is_empty() and not text.begins_with("PCH_")
	world.free()
	return ok
