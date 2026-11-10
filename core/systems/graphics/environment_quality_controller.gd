class_name EnvironmentQualityController
extends Node
## Aplica el perfil gráfico al Environment y al sol de una escena de mundo.
##
## Core no conoce las escenas de campaña: el script del mundo le pasa sus nodos
## mediante [method bind].

@export var world_environment: WorldEnvironment
@export var sun: DirectionalLight3D


func _ready() -> void:
	if GraphicsSettings != null:
		GraphicsSettings.profile_changed.connect(_on_profile_changed)
		_on_profile_changed(GraphicsSettings.get_active_profile())


## Asigna los nodos del mundo y aplica el perfil activo.
func bind(world_environment_node: WorldEnvironment, sun_node: DirectionalLight3D) -> void:
	world_environment = world_environment_node
	sun = sun_node
	if is_node_ready() and GraphicsSettings != null:
		_on_profile_changed(GraphicsSettings.get_active_profile())


func _on_profile_changed(profile: GraphicsProfile) -> void:
	if profile == null or world_environment == null:
		return
	var environment: Environment = world_environment.environment
	if environment != null:
		environment.volumetric_fog_enabled = profile.volumetric_fog_enabled
		environment.ssao_enabled = profile.ssao_enabled
		environment.ssil_enabled = profile.ssil_enabled
		environment.sdfgi_enabled = profile.sdfgi_enabled
	if sun != null:
		sun.directional_shadow_max_distance = profile.shadow_distance
