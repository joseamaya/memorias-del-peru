class_name CampaignInfo
extends Resource
## Descripción de una campaña para la pantalla de título (ADR-0024).
##
## Cada campaña guarda un recurso de este tipo con su escena de entrada y la
## clave de su subtítulo. `core/` lo lee por la ruta configurada en el ajuste
## de proyecto [constant FIRST_CAMPAIGN_SETTING], sin depender de ninguna
## campaña concreta.

## Ajuste de proyecto con la ruta del recurso de la campaña que se juega.
const FIRST_CAMPAIGN_SETTING: String = "memorias/campaign/first"

## Escena con la que empieza la campaña.
@export_file("*.tscn") var entry_scene: String = ""
## Clave de localización del subtítulo que se muestra bajo el título del juego.
@export var subtitle_key: StringName = &""


## Carga la campaña configurada en el proyecto. Devuelve `null` si el ajuste
## falta o no apunta a un [CampaignInfo].
static func load_configured() -> CampaignInfo:
	var path: String = str(ProjectSettings.get_setting(FIRST_CAMPAIGN_SETTING, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as CampaignInfo


## Indica si la escena de entrada existe.
func has_entry_scene() -> bool:
	return not entry_scene.is_empty() and ResourceLoader.exists(entry_scene)
