class_name CampaignRoute
extends Resource
## Ruta de blockout de la campaña 01.
##
## Los puntos están en coordenadas de mundo (y se apoya en el terreno al
## dibujar). La clasificación GN/GR distingue la invención necesaria de la
## reconstrucción aproximada; ninguna ruta se presenta como documentada.

@export var id: StringName = &""
@export var display_name: String = ""
@export var classification: String = "GN"
## `path` para caminos; `water` para acequias y canales.
@export var surface: StringName = &"path"
@export var width: float = 3.0
@export var points: PackedVector3Array = PackedVector3Array()


## Indica si la ruta puede usarse para blockout.
func is_valid() -> bool:
	return id != &"" and points.size() >= 2 and width > 0.0
