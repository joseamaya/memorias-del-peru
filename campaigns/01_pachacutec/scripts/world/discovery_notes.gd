class_name DiscoveryNotes
extends Node
## Entradas de diario y aviso para descubrimientos concretos.
##
## El [DiscoveryService] solo marca el POI en [WorldState]; este nodo de la
## campaña decide qué se escribe en el diario cuando se descubre un lugar que
## tiene nota propia. Al cargar se reconstruye desde las banderas de
## descubrimiento, sin serializar el diario.

const BADGE: StringName = &"N"
const SOURCE: StringName = &"PCH-039"
const HINT_SECONDS: float = 5.0

## POI → nota. Solo los que tienen texto propio; el resto se descubre sin nota.
const NOTES: Dictionary[StringName, Dictionary] = {
	&"poi_31":
	{
		"memory": &"s01_mirador_memoria",
		"title": &"PCH_S01_MIRADOR_MEM_TITULO",
		"body": &"PCH_S01_MIRADOR_MEM_CUERPO",
		"hint": &"PCH_S01_MIRADOR_AVISO",
	},
}

var _world: RegionWorld = null


## Ata el servicio de descubrimiento y reconstruye lo ya descubierto.
func setup(world: RegionWorld) -> void:
	_world = world
	if world != null:
		var discovery: DiscoveryService = world.get_discovery()
		if discovery != null:
			discovery.poi_discovered.connect(_on_discovered)
	_restore()


func _on_discovered(id: StringName) -> void:
	if not NOTES.has(id):
		return
	_add_note(id)
	_show_hint(id)


func _restore() -> void:
	var state: WorldStateService = WorldStateService.instance()
	if state == null:
		return
	for id: StringName in NOTES.keys():
		if state.is_discovered(id):
			_add_note(id)


func _add_note(id: StringName) -> void:
	var journal: Journal = _world.get_journal() if _world != null else null
	if journal == null:
		return
	var note: Dictionary = NOTES[id]
	var memory: StringName = note["memory"]
	var title: StringName = note["title"]
	var body: StringName = note["body"]
	journal.add_memory(memory, title, body, BADGE, SOURCE)


func _show_hint(id: StringName) -> void:
	var hud: PlayerHud = _world.get_player_hud() if _world != null else null
	if hud == null:
		return
	var note: Dictionary = NOTES[id]
	var hint: StringName = note["hint"]
	hud.show_hint(tr(String(hint)), HINT_SECONDS)
