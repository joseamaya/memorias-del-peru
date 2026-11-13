class_name Station
extends Interactable
## Estación del museo explorable (ADR-0034).
##
## Un marcador de piedra que se observa con E. No conoce el estado del tour ni
## la UI: solo emite [signal observed] y deja que el mundo decida qué tarjeta
## abrir y cuándo. El texto, el sello y la fuente salen de su identificador.

signal observed(station: Station)

## Identificador de la estación; de él derivan las claves de texto.
@export var station_id: StringName = &""

var enabled: bool = true
var _marker: MeshInstance3D = null


func _ready() -> void:
	# Observar no mueve las manos: es una lectura, no una acción manual.
	hand_action = &"none"
	_marker = get_node_or_null("Marker") as MeshInstance3D
	if _marker != null:
		_marker.material_override = SurfaceMaterials.layer_material(
			SurfaceMaterials.Layer.STONE, Color(0.56, 0.54, 0.50, 1.0))


## Las estaciones se desactivan cuando el evento narrativo toma el mando.
func is_available() -> bool:
	return enabled


func get_interaction_text() -> String:
	return tr("PCH_STATION_OBSERVE")


func interact(_interactor: Node3D) -> void:
	if not enabled:
		return
	observed.emit(self)


## Activa o desactiva la estación, con su marcador.
func set_enabled(value: bool) -> void:
	enabled = value
	if _marker != null:
		_marker.visible = value
