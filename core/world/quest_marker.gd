class_name QuestMarker
extends Node3D
## Señal de objetivo en el mundo: una columna tenue y un rótulo.
##
## La usan los pasos de misión para que el jugador sepa dónde ir sin abrir el
## diario. No conoce la campaña: recibe una clave de texto y un color.

const LABEL_HEIGHT: float = 2.15
const BEAM_HEIGHT: float = 2.0
const BEAM_RADIUS: float = 0.035

var _label: Label3D = null
var _beam: MeshInstance3D = null
var _color: Color = Color(0.96, 0.76, 0.28, 1.0)


func _ready() -> void:
	_build()


func setup(text_key: StringName, color: Color = Color(0.96, 0.76, 0.28, 1.0)) -> void:
	_color = color
	_build()
	set_text(text_key)


func set_text(text_key: StringName) -> void:
	_build()
	_label.text = tr(String(text_key))


func set_marker_visible(value: bool) -> void:
	visible = value


func _build() -> void:
	if _label != null:
		return
	_beam = MeshInstance3D.new()
	_beam.name = "Beam"
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = BEAM_RADIUS
	cylinder.bottom_radius = BEAM_RADIUS
	cylinder.height = BEAM_HEIGHT
	cylinder.radial_segments = 6
	_beam.mesh = cylinder
	_beam.position = Vector3(0.0, BEAM_HEIGHT * 0.5, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(_color.r, _color.g, _color.b, 0.42)
	material.emission_enabled = true
	material.emission = _color
	material.emission_energy_multiplier = 0.8
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_beam.material_override = material
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_beam.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(_beam)
	_label = Label3D.new()
	_label.name = "Label"
	_label.font_size = 42
	_label.outline_size = 8
	_label.modulate = _color
	_label.outline_modulate = Color(0.05, 0.04, 0.03, 0.9)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.position = Vector3(0.0, LABEL_HEIGHT, 0.0)
	_label.pixel_size = 0.0028
	add_child(_label)
