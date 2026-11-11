class_name PlayerHud
extends Control
## HUD mínimo y contextual.
##
## Muestra la indicación de interacción solo al enfocar un objeto, la estamina
## solo cuando no está llena y los subtítulos narrativos con duración propia
## (ADR-0006). Se comunica exclusivamente por señales y no conoce la campaña.

@export var player: PlayerFPS
@export var stamina: StaminaComponent

@onready var interaction_label: Label = $InteractionLabel
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var subtitle_label: Label = $SubtitleLabel

var _subtitle_remaining: float = 0.0


func _ready() -> void:
	_connect_refs()
	subtitle_label.visible = false


func _process(delta: float) -> void:
	advance_subtitle(delta)


## Asigna el jugador y su estamina desde la escena que compone el HUD.
func bind(player_node: PlayerFPS, stamina_node: StaminaComponent) -> void:
	player = player_node
	stamina = stamina_node
	if is_node_ready():
		_connect_refs()


## Muestra un subtítulo ya traducido durante los segundos indicados.
func show_subtitle(text: String, seconds: float) -> void:
	if text.is_empty():
		return
	subtitle_label.text = text
	subtitle_label.visible = true
	_subtitle_remaining = maxf(seconds, 0.0)


## Avanza el tiempo del subtítulo visible. Público para poder probarlo sin
## depender de los fotogramas.
func advance_subtitle(delta: float) -> void:
	if _subtitle_remaining <= 0.0:
		return
	_subtitle_remaining = maxf(_subtitle_remaining - delta, 0.0)
	if _subtitle_remaining <= 0.0:
		subtitle_label.visible = false


## Oculta el subtítulo de inmediato.
func clear_subtitle() -> void:
	_subtitle_remaining = 0.0
	subtitle_label.text = ""
	subtitle_label.visible = false


func _connect_refs() -> void:
	if player != null and not player.interactable_focused.is_connected(_on_interactable_focused):
		player.interactable_focused.connect(_on_interactable_focused)
		player.interactable_unfocused.connect(_on_interactable_unfocused)
	if stamina == null and player != null:
		stamina = player.stamina
	if stamina == null and player != null:
		stamina = StaminaComponent.find_in(player)
	if stamina != null and not stamina.stamina_changed.is_connected(_on_stamina_changed):
		stamina.stamina_changed.connect(_on_stamina_changed)
		_on_stamina_changed(stamina.get_current(), stamina.get_maximum())


func _on_interactable_focused(interactable: Interactable) -> void:
	var text: String = interactable.get_interaction_text()
	interaction_label.text = text
	interaction_label.visible = not text.is_empty()


func _on_interactable_unfocused() -> void:
	interaction_label.visible = false


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_bar.visible = current < maximum
