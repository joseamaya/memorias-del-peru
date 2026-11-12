extends RefCounted
## Comprueba el punto de entrada (ADR-0024): la escena principal es la pantalla
## de título de `core/`, y la campaña configurada lleva al mundo base.

const TITLE_SCENE: String = "res://core/ui/title_screen.tscn"
const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func test_main_scene_is_title() -> bool:
	var main_scene: String = str(ProjectSettings.get_setting("application/run/main_scene"))
	return main_scene == TITLE_SCENE


func test_configured_campaign_enters_world() -> bool:
	var campaign: CampaignInfo = CampaignInfo.load_configured()
	return campaign != null and campaign.entry_scene == WORLD_SCENE and campaign.has_entry_scene()
