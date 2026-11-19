class_name SectorDefinition
extends Resource
## Definición de un sector exterior: identidad, escena y celda de la región.
##
## `grid_position` se mide en celdas de `SectorStreamer.sector_size`. La escena
## debe tener raíz `Node3D`. `always_loaded` se usa para el sector de la
## comunidad principal o para una pieza que debe estar siempre disponible.

@export var id: StringName = &""
@export_file("*.tscn") var scene_path: String = ""
@export var grid_position: Vector2i = Vector2i.ZERO
@export var always_loaded: bool = false


## Indica si la definición puede usarse.
func is_valid() -> bool:
	if id == &"" or scene_path.is_empty():
		return false
	return ResourceLoader.exists(scene_path)
