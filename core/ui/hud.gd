class_name PlayerHud
extends Control
## HUD mínimo y contextual.
##
## Muestra la indicación de interacción solo al enfocar un objeto, la estamina
## solo cuando no está llena, los subtítulos narrativos (ADR-0006) y un rótulo
## de lugar. Los subtítulos duran lo que hace falta para leerlos y se ponen en
## cola en lugar de pisarse (ADR-0012). Se comunica exclusivamente por señales
## y no conoce la campaña. También muestra una indicación breve, como los
## controles al empezar (ADR-0024).

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

@export var player: PlayerFPS
@export var stamina: StaminaComponent

@onready var interaction_label: Label = $InteractionLabel
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var subtitle_label: Label = $SubtitleLabel
@onready var title_label: Label = $TitleLabel
@onready var hint_label: Label = $HintLabel
@onready var pause_panel: Control = $PausePanel
@onready var end_panel: ColorRect = $EndPanel
@onready var end_title: Label = $EndPanel/EndTitle
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


func _ready() -> void:
	_connect_refs()
	subtitle_label.visible = false
	title_label.visible = false
	hint_label.visible = false
	pause_panel.visible = false
	end_panel.visible = false
	# El aviso de pausa debe actualizarse con el árbol en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null and manager.has_signal("pause_changed"):
		manager.connect("pause_changed", show_pause)


func _process(delta: float) -> void:
	advance_subtitle(delta)
	advance_title(delta)
	advance_hint(delta)
	advance_end_card(delta)


## Asigna el jugador y su estamina desde la escena que compone el HUD.
func bind(player_node: PlayerFPS, stamina_node: StaminaComponent) -> void:
	player = player_node
	stamina = stamina_node
	if is_node_ready():
		_connect_refs()


## Muestra la tarjeta de fin con un fundido: título y cómo seguir.
func show_end_card(title: String, hint: String) -> void:
	end_title.text = title
	end_hint.text = hint
	end_panel.visible = true
	_end_elapsed = 0.0
	_apply_end_fade()


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


## Muestra una indicación breve (por ejemplo, los controles) con fundidos,
## durante [param seconds] en total.
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
