class_name PlayerHud
extends Control
## HUD mínimo y contextual.
##
## Muestra la indicación de interacción solo al enfocar un objeto y la estamina
## solo cuando no está llena. Se comunica exclusivamente por señales.

@export var player: PlayerFPS
@export var stamina: StaminaComponent

@onready var interaction_label: Label = $InteractionLabel
@onready var stamina_bar: ProgressBar = $StaminaBar


func _ready() -> void:
	_connect_refs()


## Asigna el jugador y su estamina desde la escena que compone el HUD.
func bind(player_node: PlayerFPS, stamina_node: StaminaComponent) -> void:
	player = player_node
	stamina = stamina_node
	if is_node_ready():
		_connect_refs()


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
	interaction_label.text = interactable.get_interaction_text()
	interaction_label.visible = true


func _on_interactable_unfocused() -> void:
	interaction_label.visible = false


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_bar.visible = current < maximum
