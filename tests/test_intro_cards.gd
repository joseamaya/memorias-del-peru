extends RefCounted
## Comprueba el componente de tarjetas de la introducción (ADR-0023): orden,
## duración de lectura, paso con `interact` y fundido final.

var _finished_count: int = 0


func _on_finished() -> void:
	_finished_count += 1


func test_intro_cards_order_and_timing() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var cards: IntroCards = IntroCards.new()
	tree.root.add_child(cards)
	_finished_count = 0
	cards.finished.connect(_on_finished)
	var texts: Array[String] = ["Primera tarjeta.", "Segunda tarjeta, algo más larga que la primera para que dure más."]
	cards.play(texts, "E para continuar")
	var ok: bool = cards.is_playing() and cards.current_index() == 0 and cards.current_text() == texts[0]
	# Dura su tiempo de lectura, con la regla de los subtítulos.
	var first: float = IntroCards.card_seconds(texts[0])
	ok = ok and is_equal_approx(first, PlayerHud.reading_seconds(texts[0]))
	ok = ok and IntroCards.card_seconds(texts[1]) > first
	cards.advance(first - 0.1)
	ok = ok and cards.current_index() == 0
	cards.advance(0.2)
	ok = ok and cards.current_index() == 1 and cards.current_text() == texts[1]
	# Tras la última, el fondo se funde y entonces termina.
	cards.advance(IntroCards.card_seconds(texts[1]) + 0.01)
	ok = ok and cards.current_index() == -1 and cards.is_playing() and _finished_count == 0
	cards.advance(IntroCards.BACKGROUND_FADE + 0.01)
	ok = ok and not cards.is_playing() and not cards.visible and _finished_count == 1
	cards.free()
	return ok


func test_intro_cards_skip() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var cards: IntroCards = IntroCards.new()
	tree.root.add_child(cards)
	var texts: Array[String] = ["Uno.", "Dos.", "Tres."]
	cards.play(texts, "")
	# Una pulsación nada más aparecer no salta la tarjeta.
	var ok: bool = not cards.skip_card() and cards.current_index() == 0
	cards.advance(IntroCards.MIN_SKIP_SECONDS + 0.01)
	ok = ok and cards.skip_card() and cards.current_index() == 1
	# La acción `interact` también avanza.
	cards.advance(IntroCards.MIN_SKIP_SECONDS + 0.01)
	var press: InputEventAction = InputEventAction.new()
	press.action = &"interact"
	press.pressed = true
	cards._unhandled_input(press)
	ok = ok and cards.current_index() == 2
	cards.free()
	return ok


func test_intro_cards_empty_finishes() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var cards: IntroCards = IntroCards.new()
	tree.root.add_child(cards)
	_finished_count = 0
	cards.finished.connect(_on_finished)
	var texts: Array[String] = []
	cards.play(texts, "")
	var ok: bool = _finished_count == 1 and not cards.is_playing()
	cards.free()
	return ok


func test_intro_cards_backdrops() -> bool:
	# Fondos por tarjeta (ADR-0025): negra, transparente y con capa propia.
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var cards: IntroCards = IntroCards.new()
	tree.root.add_child(cards)
	var overlay: Control = Control.new()
	cards.set_overlay(2, overlay)
	var shown: Array[int] = []
	cards.card_shown.connect(func(index: int, _seconds: float) -> void: shown.append(index))
	var texts: Array[String] = ["Negra.", "Transparente.", "Con capa."]
	var opaque: Array[bool] = [true, false, false]
	cards.play(texts, "", opaque)
	var ok: bool = cards.is_card_opaque(0) and is_equal_approx(cards.background_alpha(), 1.0)
	ok = ok and not overlay.visible and shown == [0]
	# La transparente funde el fondo negro hasta dejar ver lo de detrás.
	cards.advance(IntroCards.card_seconds(texts[0]) + 0.01)
	ok = ok and cards.current_index() == 1 and not cards.is_card_opaque(1)
	cards.advance(IntroCards.TEXT_FADE + 0.01)
	ok = ok and cards.background_alpha() < 0.01
	# La capa solo se ve durante su tarjeta.
	cards.advance(IntroCards.card_seconds(texts[1]))
	ok = ok and cards.current_index() == 2 and overlay.visible and shown == [0, 1, 2]
	cards.advance(IntroCards.card_seconds(texts[2]) + 0.01)
	ok = ok and not overlay.visible
	cards.free()
	return ok
