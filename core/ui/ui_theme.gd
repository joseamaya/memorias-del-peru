class_name UiTheme
extends RefCounted
## Tema compartido de la interfaz.
##
## La fuente serif y los botones oscuros con borde dorado dan una dirección
## común al título, el HUD, el diálogo y el diario. Los controles pueden seguir
## sobrescribiendo tamaños y colores concretos; el tema solo fija la base.

const FONT_PATH: String = "res://shared_assets/ui/fonts/EBGaramond-Variable.ttf"
const TEXT_COLOR: Color = Color(0.95, 0.91, 0.82, 1.0)
const MUTED_COLOR: Color = Color(0.72, 0.68, 0.60, 1.0)
const GOLD: Color = Color(0.84, 0.70, 0.40, 1.0)
const PANEL_BG: Color = Color(0.09, 0.08, 0.07, 0.94)
const BORDER: Color = Color(0.48, 0.40, 0.27, 1.0)


## Construye el tema. Devuelve un tema válido aunque falte la fuente.
static func build() -> Theme:
	var theme: Theme = Theme.new()
	theme.default_font_size = 20
	var font: Font = load(FONT_PATH) as Font
	if font != null:
		theme.default_font = font
	theme.set_color("font_color", "Label", TEXT_COLOR)
	theme.set_color("font_color", "Button", TEXT_COLOR)
	theme.set_color("font_hover_color", "Button", Color(1.0, 0.96, 0.86, 1.0))
	theme.set_color("font_pressed_color", "Button", GOLD)
	theme.set_color("font_disabled_color", "Button", Color(0.55, 0.52, 0.46, 1.0))
	theme.set_color("font_focus_color", "Button", GOLD)
	theme.set_font_size("font_size", "Button", 22)
	theme.set_stylebox("normal", "Button", _button_box(
		Color(0.08, 0.07, 0.06, 0.82), BORDER))
	theme.set_stylebox("hover", "Button", _button_box(
		Color(0.16, 0.13, 0.09, 0.92), GOLD))
	theme.set_stylebox("pressed", "Button", _button_box(
		Color(0.06, 0.05, 0.04, 0.98), GOLD))
	theme.set_stylebox("focus", "Button", _focus_box())
	theme.set_stylebox("panel", "PanelContainer", _panel_box())
	return theme


static func _button_box(background: Color, border: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(3)
	box.content_margin_left = 18.0
	box.content_margin_right = 18.0
	box.content_margin_top = 8.0
	box.content_margin_bottom = 8.0
	return box


static func _focus_box() -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	box.border_color = GOLD
	box.set_border_width_all(2)
	box.set_corner_radius_all(3)
	return box


static func _panel_box() -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = PANEL_BG
	box.border_color = BORDER
	box.set_border_width_all(1)
	box.set_corner_radius_all(4)
	return box
