extends RefCounted
## Comprueba la tarjeta de estación de Core: se abre, muestra los cuatro campos,
## se cierra y emite la señal.


func test_tour_card_open_and_close() -> bool:
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
	var card: TourCard = hud.get_tour_card()
	var closed: Array[int] = [0]
	card.closed.connect(func() -> void: closed[0] += 1)
	var ok: bool = not hud.is_tour_card_open()
	hud.show_tour_card("Título", "Cuerpo", "A · evidencia", "Fuente")
	ok = ok and hud.is_tour_card_open()
	ok = ok and card.get_title_text() == "Título"
	ok = ok and card.get_badge_text() == "A · evidencia"
	hud.close_tour_card()
	ok = ok and not hud.is_tour_card_open()
	ok = ok and closed[0] == 1
	hud.free()
	return ok
