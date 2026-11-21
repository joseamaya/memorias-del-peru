class_name RegionUi
extends Node
## Interfaz del mundo regional: HUD, diario y conversaciones.
##
## Vive aparte de [RegionWorld] para que el mundo no mezcle streaming, jugador
## e interfaz. La UI no conoce campañas: los grafos se registran por carpeta y
## los textos llegan por clave de localización.

signal journal_closed

const HUD_SCENE: String = "res://core/ui/hud.tscn"
## Grafos de diálogo de la campaña, con el nombre del archivo como ID.
const DIALOGUE_DIR: String = "res://campaigns/01_pachacutec/data/dialogues"

var hud: PlayerHud = null
var journal: Journal = null
var dialogue: DialoguePresenter = null
var player: PlayerFPS = null
var combat: PlayerCombat = null


## Monta HUD, diario y presentador. Debe llamarse con el jugador ya creado.
func setup(player_node: PlayerFPS) -> void:
	player = player_node
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "UI"
	add_child(layer)
	var packed: PackedScene = load(HUD_SCENE) as PackedScene
	if packed == null:
		push_error("RegionUi: no se encontró el HUD.")
		return
	hud = packed.instantiate() as PlayerHud
	if hud == null:
		push_error("RegionUi: el HUD no es PlayerHud.")
		return
	hud.name = "HUD"
	layer.add_child(hud)
	hud.bind(player, null)
	hud.journal_closed.connect(_on_journal_closed)
	combat = PlayerCombat.new()
	combat.name = "Combat"
	player.add_child(combat)
	combat.setup(player, hud)
	journal = Journal.new()
	journal.name = "Journal"
	add_child(journal)
	dialogue = DialoguePresenter.new()
	dialogue.name = "Dialogue"
	add_child(dialogue)
	dialogue.setup(hud, player)
	dialogue.register_directory(DIALOGUE_DIR)


## Abre o cierra el diario. Mientras está abierto, el jugador no se mueve.
func toggle_journal() -> void:
	if hud == null or journal == null:
		return
	if hud.is_journal_open():
		hud.hide_journal()
		return
	if dialogue != null and dialogue.is_active():
		return
	hud.show_journal(journal)
	if player != null:
		player.set_controls_locked(true)


func close_journal() -> void:
	if hud != null and hud.is_journal_open():
		hud.hide_journal()


func is_journal_open() -> bool:
	return hud != null and hud.is_journal_open()


func _on_journal_closed() -> void:
	journal_closed.emit()
