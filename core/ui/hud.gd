class_name PlayerHud
extends Control
## HUD mínimo y contextual.
##
## Muestra la indicación de interacción solo al enfocar un objeto, la salud y la
## estamina solo cuando no están llenas (o durante el combate), los subtítulos
## narrativos y un rótulo de lugar. Los subtítulos duran lo que hace falta para
## leerlos y se ponen en cola en lugar de pisarse. Se comunica exclusivamente
## por señales y no conoce la campaña.
##
## Durante un diálogo o el diario se retira todo el HUD de exploración y, en el
## diálogo, aparecen dos bandas cinematográficas. El centro de la pantalla lleva
## una retícula discreta que se abre al enfocar un interactuable.

## Velocidad de lectura supuesta y margen añadido a cada subtítulo.
const CHARS_PER_SECOND: float = 13.0
const READING_PADDING: float = 1.5
const MIN_SUBTITLE_SECONDS: float = 4.0
## Pausa entre dos subtítulos seguidos, para que se note el cambio.
const SUBTITLE_GAP: float = 0.3
## Subtítulos en espera como máximo; si se llena, se descarta el más antiguo.
const QUEUE_LIMIT: int = 4
## Fundido de la tarjeta de fin y opacidad final del fondo.
const END_FADE: float = 2.0
const END_ALPHA: float = 0.85
## Fundidos del rótulo de lugar.
const TITLE_FADE_IN: float = 0.8
const TITLE_FADE_OUT: float = 1.2
## Bandas cinematográficas del diálogo y velocidad de su entrada.
const CINEMATIC_BAR_HEIGHT: float = 64.0
const CINEMATIC_SECONDS: float = 0.28
## Retícula: radio del punto y del anillo de enfoque.
const RETICLE_DOT_RADIUS: float = 2.0
const RETICLE_RING_RADIUS: float = 7.0
const RETICLE_IDLE_ALPHA: float = 0.42
const RETICLE_FOCUS_ALPHA: float = 0.9

## Se emite al avanzar una línea de diálogo sin opciones.
signal dialogue_advanced
## Se emite al elegir una opción de diálogo, por su índice visible.
signal dialogue_choice(index: int)
## Se emite al cerrar el diario.
signal journal_closed

@export var player: PlayerFPS
@export var stamina: StaminaComponent

@onready var interaction_label: Label = $InteractionLabel
@onready var interaction_key: Label = $InteractionKey
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var status_label: Label = $StatusLabel
@onready var health_vignette: ColorRect = $HealthVignette
@onready var ammo_label: Label = $AmmoLabel
@onready var damage_flash: ColorRect = $DamageFlash
@onready var cinematic_top: ColorRect = $CinematicTop
@onready var cinematic_bottom: ColorRect = $CinematicBottom
@onready var subtitle_label: Label = $SubtitleLabel
@onready var title_label: Label = $TitleLabel
@onready var hint_label: Label = $HintLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var dialogue_panel: DialoguePanel = $DialoguePanel
@onready var journal_panel: JournalPanel = $JournalPanel
@onready var pause_panel: Control = $PausePanel
@onready var end_panel: ColorRect = $EndPanel
@onready var end_title: Label = $EndPanel/EndTitle
@onready var end_body: Label = $EndPanel/EndBody
@onready var end_hint: Label = $EndPanel/EndHint

var _subtitle_remaining: float = 0.0
var _gap_remaining: float = 0.0
var _queue_texts: Array[String] = []
var _queue_seconds: Array[float] = []
var _title_total: float = 0.0
var _title_elapsed: float = 0.0
var _hint_total: float = 0.0
var _hint_elapsed: float = 0.0
var _end_elapsed: float = -1.0
var _character: CharacterState = null
var _status_visible: bool = false
var _cinematic: bool = false
var _reticle_focused: bool = false
var _exploration_visible: bool = true
var _cinematic_tween: Tween = null
var _ammo_sling: bool = false
var _ammo_remaining: int = 0
var _vignette_base: float = 0.0


func _ready() -> void:
	theme = UiTheme.build()
	_connect_refs()
	subtitle_label.visible = false
	title_label.visible = false
	hint_label.visible = false
	objective_label.visible = false
	interaction_label.visible = false
	interaction_key.visible = false
	health_bar.visible = false
	health_label.visible = false
	stamina_bar.visible = false
	var stamina_caption: Label = get_node_or_null("StaminaLabel") as Label
	if stamina_caption != null:
		stamina_caption.visible = false
	status_label.visible = false
	ammo_label.visible = false
	_set_vignette(0.0)
	pause_panel.visible = false
	end_panel.visible = false
	cinematic_top.visible = true
	cinematic_bottom.visible = true
	_set_cinematic_offset(0.0)
	dialogue_panel.advanced.connect(_on_dialogue_advanced)
	dialogue_panel.choice_selected.connect(_on_dialogue_choice)
	journal_panel.closed.connect(_on_journal_closed)
	# El aviso de pausa debe actualizarse con el árbol en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null and manager.has_signal("pause_changed"):
		manager.connect("pause_changed", show_pause)


func _process(delta: float) -> void:
	_ensure_character()
	advance_subtitle(delta)
	advance_title(delta)
	advance_hint(delta)
	advance_end_card(delta)


## Retícula central: un punto tenue y un anillo que se abre al enfocar.
func _draw() -> void:
	if not _exploration_visible or _cinematic or pause_panel.visible or end_panel.visible:
		return
	var center: Vector2 = size * 0.5
	var alpha: float = RETICLE_FOCUS_ALPHA if _reticle_focused else RETICLE_IDLE_ALPHA
	var color: Color = Color(0.97, 0.93, 0.82, alpha)
	draw_circle(center, RETICLE_DOT_RADIUS, color)
	if _reticle_focused:
		draw_arc(center, RETICLE_RING_RADIUS, 0.0, TAU, 24, color, 1.4, true)


## Asigna el jugador y su estamina desde la escena que compone el HUD.
func bind(player_node: PlayerFPS, stamina_node: StaminaComponent) -> void:
	player = player_node
	stamina = stamina_node
	if is_node_ready():
		_connect_refs()


## Muestra u oculta una línea de estado de combate (enemigos, aliados).
func set_status(text: String) -> void:
	_ensure_character()
	_status_visible = not text.is_empty()
	status_label.text = text
	_refresh_vitals_visibility()
	_refresh_status_visibility()


## Indica si el estado de combate está a la vista.
func is_status_visible() -> bool:
	return status_label.visible


## Indica si la salud está a la vista.
func is_health_visible() -> bool:
	return health_bar.visible


## Entra o sale del modo cinematográfico del diálogo: bandas arriba y abajo y
## el HUD de exploración fuera de la pantalla.
func set_cinematic(active: bool) -> void:
	if _cinematic == active:
		return
	_cinematic = active
	_exploration_visible = not active
	_refresh_interaction_visibility()
	_refresh_vitals_visibility()
	_refresh_status_visibility()
	_refresh_ammo_visibility()
	objective_label.visible = not active and not objective_label.text.is_empty()
	if _cinematic_tween != null and _cinematic_tween.is_valid():
		_cinematic_tween.kill()
	_cinematic_tween = create_tween()
	_cinematic_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var target: float = CINEMATIC_BAR_HEIGHT if active else 0.0
	_cinematic_tween.tween_method(_set_cinematic_offset, _current_cinematic_offset(), target, CINEMATIC_SECONDS)
	queue_redraw()


## Indica si el HUD está en modo cinematográfico.
func is_cinematic() -> bool:
	return _cinematic


## Destello breve al recibir daño. La viñeta de salud pulsa y vuelve a su base.
func flash_damage() -> void:
	damage_flash.color = Color(0.55, 0.08, 0.05, 0.34)
	var tween: Tween = create_tween()
	tween.tween_property(damage_flash, "color:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD)
	var vignette_tween: Tween = create_tween()
	vignette_tween.tween_method(_set_vignette,
		clampf(_vignette_base + 0.32, 0.0, 1.0), _vignette_base, 0.55) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Fuerza de la viñeta de salud (0–1), para pruebas y ajustes.
func vignette_strength() -> float:
	if health_vignette == null or health_vignette.material == null:
		return 0.0
	var shader_material: ShaderMaterial = health_vignette.material as ShaderMaterial
	if shader_material == null:
		return 0.0
	var raw: Variant = shader_material.get_shader_parameter("strength")
	if raw is float:
		return raw
	return 0.0


## Munición visible junto a la mano. La honda es la única que gasta piedras.
func set_ammo(remaining: int, sling: bool) -> void:
	_ammo_remaining = remaining
	_ammo_sling = sling
	ammo_label.text = tr("UI_AMMO_STONES") % remaining
	_refresh_ammo_visibility()


## Indica si la munición está a la vista.
func is_ammo_visible() -> bool:
	return ammo_label.visible


func _current_cinematic_offset() -> float:
	return cinematic_top.offset_bottom


func _set_cinematic_offset(value: float) -> void:
	cinematic_top.offset_bottom = value
	cinematic_bottom.offset_top = -value


## Muestra la tarjeta de fin con un fundido: título, cuerpo opcional y cómo seguir.
func show_end_card(title: String, hint: String, body: String = "") -> void:
	clear_subtitle()
	if player != null:
		# La tarjeta es modal: sin esto el jugador seguía caminando e
		# interactuando detrás del fundido y podía disparar otra acción.
		player.set_controls_locked(true)
	end_title.text = title
	end_body.text = body
	end_body.visible = not body.is_empty()
	end_hint.text = hint
	end_panel.visible = true
	_end_elapsed = 0.0
	_exploration_visible = false
	interaction_label.visible = false
	interaction_key.visible = false
	health_bar.visible = false
	health_label.visible = false
	stamina_bar.visible = false
	status_label.visible = false
	ammo_label.visible = false
	objective_label.visible = false
	damage_flash.color = Color(0.55, 0.08, 0.05, 0.0)
	_set_vignette(0.0)
	_apply_end_fade()
	queue_redraw()


## Avanza el fundido de la tarjeta de fin.
func advance_end_card(delta: float) -> void:
	if _end_elapsed < 0.0 or _end_elapsed >= END_FADE:
		return
	_end_elapsed = minf(_end_elapsed + delta, END_FADE)
	_apply_end_fade()


## Indica si la tarjeta de fin está a la vista.
func is_end_card_visible() -> bool:
	return end_panel.visible


func _apply_end_fade() -> void:
	var t: float = clampf(_end_elapsed / END_FADE, 0.0, 1.0)
	end_panel.color = Color(0.0, 0.0, 0.0, END_ALPHA * t)
	end_title.modulate.a = t
	end_hint.modulate.a = t


## Muestra u oculta el aviso de pausa.
func show_pause(paused: bool) -> void:
	pause_panel.visible = paused
	queue_redraw()


## Segundos que necesita [param text] para leerse con calma; nunca menos que
## [param requested] ni que [constant MIN_SUBTITLE_SECONDS].
static func reading_seconds(text: String, requested: float = 0.0) -> float:
	var needed: float = float(text.length()) / CHARS_PER_SECOND + READING_PADDING
	return maxf(maxf(requested, MIN_SUBTITLE_SECONDS), needed)


## Muestra un subtítulo ya traducido. Dura al menos [param seconds] y lo que
## haga falta para leerlo. Si ya hay uno a la vista, espera su turno.
func show_subtitle(text: String, seconds: float) -> void:
	if text.is_empty():
		return
	var duration: float = reading_seconds(text, seconds)
	if not is_showing_subtitle():
		_display_subtitle(text, duration)
		return
	if text == subtitle_label.text or (not _queue_texts.is_empty() and _queue_texts.back() == text):
		return
	if _queue_texts.size() >= QUEUE_LIMIT:
		_queue_texts.pop_front()
		_queue_seconds.pop_front()
	_queue_texts.append(text)
	_queue_seconds.append(duration)


## Indica si hay un subtítulo a la vista o a punto de mostrarse.
func is_showing_subtitle() -> bool:
	return _subtitle_remaining > 0.0 or _gap_remaining > 0.0 or not _queue_texts.is_empty()


## Subtítulos en espera (sin contar el visible).
func queued_subtitles() -> int:
	return _queue_texts.size()


## Avanza el tiempo del subtítulo visible y de la cola. Público para poder
## probarlo sin depender de los fotogramas.
func advance_subtitle(delta: float) -> void:
	if _subtitle_remaining > 0.0:
		_subtitle_remaining = maxf(_subtitle_remaining - delta, 0.0)
		if _subtitle_remaining <= 0.0:
			subtitle_label.visible = false
			_gap_remaining = SUBTITLE_GAP if not _queue_texts.is_empty() else 0.0
		return
	if _gap_remaining > 0.0:
		_gap_remaining = maxf(_gap_remaining - delta, 0.0)
		if _gap_remaining > 0.0:
			return
	if not _queue_texts.is_empty():
		var text: String = _queue_texts.pop_front()
		var duration: float = _queue_seconds.pop_front()
		_display_subtitle(text, duration)


## Oculta el subtítulo y vacía la cola de inmediato.
func clear_subtitle() -> void:
	_subtitle_remaining = 0.0
	_gap_remaining = 0.0
	_queue_texts.clear()
	_queue_seconds.clear()
	subtitle_label.text = ""
	subtitle_label.visible = false


## Muestra un rótulo (por ejemplo, el lugar y la época) con fundidos, durante
## [param seconds] en total.
func show_title(text: String, seconds: float) -> void:
	if text.is_empty() or seconds <= 0.0:
		return
	title_label.text = text
	title_label.visible = true
	title_label.modulate.a = 0.0
	_title_total = seconds
	_title_elapsed = 0.0


## Avanza los fundidos del rótulo.
func advance_title(delta: float) -> void:
	if not title_label.visible:
		return
	_title_elapsed += delta
	if _title_elapsed >= _title_total:
		title_label.visible = false
		return
	var fade_in: float = clampf(_title_elapsed / TITLE_FADE_IN, 0.0, 1.0)
	var fade_out: float = clampf((_title_total - _title_elapsed) / TITLE_FADE_OUT, 0.0, 1.0)
	title_label.modulate.a = minf(fade_in, fade_out)


## Muestra el objetivo actual en una sola línea, sin fondo ni adornos. Es la
## respuesta permanente a «¿qué hago ahora?»: se actualiza cuando cambia el
## paso, no parpadea y no compite con los subtítulos.
func show_objective(text: String) -> void:
	objective_label.text = text
	objective_label.visible = not text.is_empty()


## Retira el objetivo (por ejemplo, al terminar la experiencia).
func clear_objective() -> void:
	show_objective("")


## Texto del objetivo a la vista, o cadena vacía.
func get_objective_text() -> String:
	return objective_label.text


## Indica si hay un objetivo a la vista.
func is_showing_objective() -> bool:
	return objective_label.visible


## Abre el panel de diálogo con textos ya traducidos.
func show_dialogue(speaker: String, text: String, choices: Array[String]) -> void:
	if not dialogue_panel.is_open():
		set_cinematic(true)
	dialogue_panel.open(speaker, text, choices)


## Sustituye la línea de diálogo sin cerrar el panel.
func update_dialogue(speaker: String, text: String, choices: Array[String]) -> void:
	dialogue_panel.set_line(speaker, text, choices)


## Cierra el panel de diálogo.
func hide_dialogue() -> void:
	dialogue_panel.close()
	set_cinematic(false)


## Indica si el diálogo está abierto.
func is_dialogue_open() -> bool:
	return dialogue_panel.is_open()


## Abre el diario con las entradas del jugador.
func show_journal(journal: Journal) -> void:
	_exploration_visible = false
	interaction_label.visible = false
	interaction_key.visible = false
	objective_label.visible = false
	_refresh_vitals_visibility()
	_refresh_status_visibility()
	journal_panel.open(journal)
	if player != null:
		player.set_pointer_visible(true)
	queue_redraw()


## Cierra el diario.
func hide_journal() -> void:
	journal_panel.close()
	_exploration_visible = true
	objective_label.visible = not objective_label.text.is_empty()
	_refresh_vitals_visibility()
	_refresh_status_visibility()
	if player != null:
		player.set_pointer_visible(false)
	queue_redraw()


## Indica si el diario está abierto.
func is_journal_open() -> bool:
	return journal_panel.is_open()


## Panel de diálogo, para las pruebas.
func get_dialogue_panel() -> DialoguePanel:
	return dialogue_panel


## Panel del diario, para las pruebas.
func get_journal_panel() -> JournalPanel:
	return journal_panel


func _on_dialogue_advanced() -> void:
	dialogue_advanced.emit()


func _on_dialogue_choice(index: int) -> void:
	dialogue_choice.emit(index)


func _on_journal_closed() -> void:
	journal_closed.emit()


func show_hint(text: String, seconds: float) -> void:
	if text.is_empty() or seconds <= 0.0:
		return
	hint_label.text = text
	hint_label.visible = true
	hint_label.modulate.a = 0.0
	_hint_total = seconds
	_hint_elapsed = 0.0


## Indica si la indicación breve está a la vista.
func is_showing_hint() -> bool:
	return hint_label.visible


## Avanza los fundidos de la indicación breve.
func advance_hint(delta: float) -> void:
	if not hint_label.visible:
		return
	_hint_elapsed += delta
	if _hint_elapsed >= _hint_total:
		hint_label.visible = false
		return
	var fade_in: float = clampf(_hint_elapsed / TITLE_FADE_IN, 0.0, 1.0)
	var fade_out: float = clampf((_hint_total - _hint_elapsed) / TITLE_FADE_OUT, 0.0, 1.0)
	hint_label.modulate.a = minf(fade_in, fade_out)


func _display_subtitle(text: String, duration: float) -> void:
	subtitle_label.text = text
	subtitle_label.visible = true
	_subtitle_remaining = duration
	_gap_remaining = 0.0


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
	_ensure_character()


## El estado del jugador puede crearse después del bind (Paso y Cusco montan el
## combate más tarde): se busca de forma perezosa y se conecta una sola vez.
func _ensure_character() -> void:
	if _character != null and is_instance_valid(_character):
		return
	if player == null:
		return
	_character = player.get_node_or_null("CharacterState") as CharacterState
	if _character == null:
		_character = player.find_child("CharacterState", true, false) as CharacterState
	if _character == null:
		return
	if not _character.health_changed.is_connected(_on_health_changed):
		_character.health_changed.connect(_on_health_changed)
	_on_health_changed(_character.get_health(), _character.get_max_health())


func _on_interactable_focused(interactable: Interactable) -> void:
	var text: String = interactable.get_interaction_text()
	interaction_label.text = text
	_reticle_focused = true
	_refresh_interaction_visibility()
	queue_redraw()


func _on_interactable_unfocused() -> void:
	_reticle_focused = false
	_refresh_interaction_visibility()
	queue_redraw()


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	_refresh_vitals_visibility()


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	_vignette_base = clampf(1.0 - current / maxf(maximum, 1.0), 0.0, 1.0) * 0.85
	_set_vignette(_vignette_base)
	_refresh_vitals_visibility()


## La interacción solo se ve durante la exploración y con un objeto enfocado.
func _refresh_interaction_visibility() -> void:
	var visible_now: bool = _exploration_visible and not _cinematic and not interaction_label.text.is_empty()
	interaction_label.visible = visible_now
	interaction_key.visible = visible_now


## La salud se lee en la viñeta; la estamina, en la barra que solo aparece
## cuando baja. La barra de salud fija se retiró para cumplir la biblia §3.3.
func _refresh_vitals_visibility() -> void:
	var can_show: bool = _exploration_visible and not _cinematic
	health_bar.visible = false
	health_label.visible = false
	var stamina_active: bool = stamina != null and stamina.get_current() < stamina.get_maximum()
	stamina_bar.visible = can_show and stamina_active
	var stamina_label: Label = get_node_or_null("StaminaLabel") as Label
	if stamina_label != null:
		stamina_label.visible = stamina_bar.visible


func _refresh_status_visibility() -> void:
	status_label.visible = _status_visible and _exploration_visible and not _cinematic


func _refresh_ammo_visibility() -> void:
	ammo_label.visible = _exploration_visible and not _cinematic and _ammo_sling


func _set_vignette(value: float) -> void:
	if health_vignette == null or health_vignette.material == null:
		return
	var shader_material: ShaderMaterial = health_vignette.material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("strength", clampf(value, 0.0, 1.0))
