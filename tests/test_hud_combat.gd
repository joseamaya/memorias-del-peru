extends RefCounted
## Comprueba la viñeta de salud y la munición en el HUD.

const HUD: String = "res://core/ui/hud.tscn"


func test_hud_vignette_and_ammo() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(HUD) as PackedScene
	if packed == null:
		return false
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	if hud == null:
		return false
	tree.root.add_child(hud)
	hud.call("_set_vignette", 0.6)
	var ok: bool = is_equal_approx(hud.vignette_strength(), 0.6)
	hud.set_ammo(7, true)
	ok = ok and hud.is_ammo_visible()
	hud.set_ammo(7, false)
	ok = ok and not hud.is_ammo_visible()
	hud.free()
	return ok
