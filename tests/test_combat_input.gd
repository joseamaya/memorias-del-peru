extends RefCounted
## Comprueba la munición ligada al arma equipada y el clic del escudo.

const PLAYER_PATH: String = "res://core/player/player_fps.tscn"
const HUD_PATH: String = "res://core/ui/hud.tscn"


func _spawn() -> Array[Node]:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return []
	var player_packed: PackedScene = load(PLAYER_PATH) as PackedScene
	var hud_packed: PackedScene = load(HUD_PATH) as PackedScene
	if player_packed == null or hud_packed == null:
		return []
	var player: PlayerFPS = player_packed.instantiate() as PlayerFPS
	var hud: PlayerHud = hud_packed.instantiate() as PlayerHud
	if player == null or hud == null:
		return []
	tree.root.add_child(player)
	tree.root.add_child(hud)
	var combat: PlayerCombat = PlayerCombat.new()
	combat.name = "Combat"
	player.add_child(combat)
	combat.setup(player, hud)
	var nodes: Array[Node] = [player, hud, combat]
	return nodes


func _free_nodes(nodes: Array[Node]) -> void:
	for node: Node in nodes:
		if is_instance_valid(node):
			node.free()


func test_ammo_follows_armed_state() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var hud: PlayerHud = nodes[1] as PlayerHud
	var combat: PlayerCombat = nodes[2] as PlayerCombat
	var ok: bool = not combat.is_armed() and not hud.is_ammo_visible()
	combat.set_armed(true)
	ok = ok and combat.is_armed() and hud.is_ammo_visible()
	combat.select_weapon(CombatLoadout.Slot.CLUB)
	ok = ok and not hud.is_ammo_visible()
	combat.select_weapon(CombatLoadout.Slot.SLING)
	ok = ok and hud.is_ammo_visible()
	_free_nodes(nodes)
	return ok


func test_weapon_hidden_while_controls_locked() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var player: PlayerFPS = nodes[0] as PlayerFPS
	var combat: PlayerCombat = nodes[2] as PlayerCombat
	var weapon: Node3D = player.get_node("Head/Camera3D/FirstPersonWeapon") as Node3D
	combat.set_armed(true)
	combat.call("_process", 0.0)
	var ok: bool = weapon.visible
	player.set_controls_locked(true)
	combat.call("_process", 0.0)
	ok = ok and not weapon.visible
	player.set_controls_locked(false)
	combat.call("_process", 0.0)
	ok = ok and weapon.visible
	combat.set_armed(false)
	player.set_controls_locked(true)
	player.set_controls_locked(false)
	combat.call("_process", 0.0)
	ok = ok and not weapon.visible
	_free_nodes(nodes)
	return ok


func test_shield_click_releases_block() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var combat: PlayerCombat = nodes[2] as PlayerCombat
	combat.set_armed(true)
	combat.select_weapon(CombatLoadout.Slot.SHIELD)
	combat.call("_start_charge")
	var ok: bool = combat.loadout.is_blocking()
	combat.call("_release_charge")
	ok = ok and not combat.loadout.is_blocking()
	_free_nodes(nodes)
	return ok


func test_release_while_controls_locked_cancels_charge() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var player: PlayerFPS = nodes[0] as PlayerFPS
	var combat: PlayerCombat = nodes[2] as PlayerCombat
	combat.set_armed(true)
	combat.select_weapon(CombatLoadout.Slot.CLUB)
	combat.call("_start_charge")
	var ok: bool = combat.is_charging()
	player.set_controls_locked(true)
	var release: InputEventAction = InputEventAction.new()
	release.action = &"attack"
	release.pressed = false
	combat._unhandled_input(release)
	ok = ok and not combat.is_charging()
	ok = ok and not combat.loadout.is_attacking()
	_free_nodes(nodes)
	return ok


func test_charge_cancels_when_release_is_lost() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var combat: PlayerCombat = nodes[2] as PlayerCombat
	combat.set_armed(true)
	combat.select_weapon(CombatLoadout.Slot.CLUB)
	combat.call("_start_charge")
	var charging: bool = combat.is_charging()
	# La suelta no llegó (pausa, cambio de ventana): el botón ya no está pulsado.
	combat.call("_process", 0.2)
	var ok: bool = charging and not combat.is_charging()
	ok = ok and not combat.loadout.is_attacking()
	_free_nodes(nodes)
	return ok


func test_block_release_lost_in_pause_lowers_shield() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var combat: PlayerCombat = nodes[2] as PlayerCombat
	combat.set_armed(true)
	combat.select_weapon(CombatLoadout.Slot.SHIELD)
	# El botón derecho se pulsa y el evento llega; la suelta se pierde en pausa.
	Input.action_press(&"block")
	var press: InputEventAction = InputEventAction.new()
	press.action = &"block"
	press.pressed = true
	combat._unhandled_input(press)
	var raised: bool = combat.loadout.is_blocking()
	Input.action_release(&"block")
	combat.call("_process", 0.2)
	var ok: bool = raised and not combat.loadout.is_blocking()
	_free_nodes(nodes)
	return ok


func test_block_stays_raised_while_button_is_held() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var combat: PlayerCombat = nodes[2] as PlayerCombat
	combat.set_armed(true)
	combat.select_weapon(CombatLoadout.Slot.SHIELD)
	Input.action_press(&"block")
	var press: InputEventAction = InputEventAction.new()
	press.action = &"block"
	press.pressed = true
	combat._unhandled_input(press)
	combat.call("_process", 0.2)
	var ok: bool = combat.loadout.is_blocking()
	Input.action_release(&"block")
	combat.call("_process", 0.2)
	ok = ok and not combat.loadout.is_blocking()
	_free_nodes(nodes)
	return ok
