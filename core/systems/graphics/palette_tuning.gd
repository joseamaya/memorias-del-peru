class_name PaletteTuning
extends Resource
## Paleta de un acto: cielo, sol, ambiente, niebla y ajuste de imagen.
##
## Es el contrato entre la guía visual y las escenas. Un cambio de color se hace
## aquí, no en cada `.tscn`: así los cinco actos comparten una dirección y se
## pueden comparar sin abrir el editor. El recurso no conoce la campaña; cada
## escena le pasa el suyo a [EnvironmentQualityController].

@export var display_name: String = ""

@export_group("Cielo")
## Color de Rayleigh del cielo físico. Azul alto, más claro en la bruma.
@export var sky_rayleigh: Color = Color(0.30, 0.50, 0.90, 1.0)
## Color del suelo del cielo; evita que el horizonte se lea como un corte.
@export var sky_ground: Color = Color(0.18, 0.16, 0.13, 1.0)
@export_range(0.0, 10.0, 0.1) var sky_turbidity: float = 1.5
@export var sky_mie: Color = Color(0.85, 0.75, 0.65, 1.0)
@export_range(0.0, 2.0, 0.05) var sky_energy: float = 1.0

@export_group("Sol")
@export var sun_color: Color = Color(1.0, 0.86, 0.68, 1.0)
@export_range(0.0, 4.0, 0.05) var sun_energy: float = 1.25
@export_range(-90.0, 0.0, 1.0) var sun_elevation_deg: float = -22.0
@export_range(-180.0, 180.0, 1.0) var sun_azimuth_deg: float = -40.0

@export_group("Ambiente")
@export var ambient_color: Color = Color(0.72, 0.68, 0.61, 1.0)
@export_range(0.0, 3.0, 0.05) var ambient_energy: float = 0.95
@export_range(0.0, 1.0, 0.05) var ambient_sky_contribution: float = 0.42

@export_group("Niebla")
@export var fog_color: Color = Color(0.66, 0.74, 0.86, 1.0)
@export_range(0.0, 0.02, 0.0001) var fog_density: float = 0.0016
@export_range(-100.0, 100.0, 1.0) var fog_height: float = 0.0
@export_range(0.0, 1.0, 0.01) var fog_height_density: float = 0.05
@export_range(0.0, 1.0, 0.01) var fog_sky_affect: float = 0.35

@export_group("Imagen")
@export_range(0.2, 3.0, 0.01) var exposure: float = 1.05
@export_range(0.5, 1.5, 0.01) var contrast: float = 1.06
@export_range(0.0, 2.0, 0.01) var saturation: float = 1.0
@export_range(0.0, 2.0, 0.01) var background_energy: float = 1.0


## Aplica la paleta al cielo, al sol y al ambiente de una escena.
##
## Es idempotente: se puede llamar al cambiar de perfil gráfico o al entrar en
## un acto sin acumular cambios. No toca la niebla volumétrica ni el SSAO; esos
## siguen siendo responsabilidad de [EnvironmentQualityController].
func apply_to(world_environment: WorldEnvironment, sun: DirectionalLight3D) -> void:
	if world_environment == null:
		return
	var environment: Environment = world_environment.environment
	if environment == null:
		environment = Environment.new()
		world_environment.environment = environment
	_apply_sky(environment)
	environment.ambient_light_color = ambient_color
	environment.ambient_light_energy = ambient_energy
	environment.ambient_light_sky_contribution = ambient_sky_contribution
	environment.fog_enabled = true
	environment.fog_light_color = fog_color
	environment.fog_density = fog_density
	environment.fog_height = fog_height
	environment.fog_height_density = fog_height_density
	environment.fog_sky_affect = fog_sky_affect
	environment.tonemap_exposure = exposure
	environment.adjustment_enabled = true
	environment.adjustment_contrast = contrast
	environment.adjustment_saturation = saturation
	environment.background_energy_multiplier = background_energy
	if sun != null:
		sun.light_color = sun_color
		sun.light_energy = sun_energy
		sun.rotation_degrees = Vector3(sun_elevation_deg, sun_azimuth_deg, 0.0)


func _apply_sky(environment: Environment) -> void:
	var sky: Sky = environment.sky
	if sky == null:
		return
	var material: Material = sky.sky_material
	if material is PhysicalSkyMaterial:
		var physical: PhysicalSkyMaterial = material as PhysicalSkyMaterial
		physical.rayleigh_color = sky_rayleigh
		physical.ground_color = sky_ground
		physical.turbidity = sky_turbidity
		physical.mie_color = sky_mie
		physical.energy_multiplier = sky_energy
	elif material is ProceduralSkyMaterial:
		var procedural: ProceduralSkyMaterial = material as ProceduralSkyMaterial
		procedural.sky_top_color = sky_rayleigh
		procedural.sky_horizon_color = fog_color
		procedural.ground_horizon_color = fog_color
		procedural.ground_bottom_color = sky_ground
