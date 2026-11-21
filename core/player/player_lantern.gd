class_name PlayerLantern
extends Node3D
## Antorcha de mano del jugador para caminar de noche.
##
## Se enciende sola cuando el sol baja, con [method DayNightCycle.daylight_at],
## y se apaga de día. La malla y la mano son de bloqueo, como el arma en
## primera persona; la luz no proyecta sombras para no encarecer la escena.
##
## Clasificación histórica: R (antorcha de mano), ver PCH-042.

const REST_POSITION: Vector3 = Vector3(-0.42, -0.40, -0.62)
const REST_ROTATION: Vector3 = Vector3(-6.0, -22.0, -14.0)
## Escala de la malla: el palo real mediría 0,5 m y en pantalla ocuparía media
## vista. La luz vive fuera de esta escala para conservar su alcance en metros.
const VISUAL_SCALE: float = 0.55
## Energía de la luz con la noche cerrada.
const MAX_ENERGY: float = 1.55
const LIGHT_RANGE: float = 10.0
const LIGHT_COLOR: Color = Color(1.0, 0.72, 0.44)
## Parpadeo: variación relativa de la energía y velocidad del ciclo.
const FLICKER_AMOUNT: float = 0.07
const FLICKER_SPEED: float = 6.7
## Luz diurna por debajo de la cual la antorcha empieza a encenderse.
const OFF_DAYLIGHT: float = 0.22
## Nivel mínimo para que la malla y la luz se muestren.
const MIN_LEVEL: float = 0.02

var _light: OmniLight3D = null
var _visual: Node3D = null
var _time: float = 0.0
var _level: float = 0.0


func _ready() -> void:
	_build_torch()
	position = REST_POSITION
	rotation_degrees = REST_ROTATION
	set_lit(0.0)


func _process(delta: float) -> void:
	_time += delta
	var flicker: float = 1.0 + sin(_time * FLICKER_SPEED) * FLICKER_AMOUNT
	set_lit(_target_level() * flicker)


## Fuerza un nivel de luz (0–1). Las pruebas y las capturas lo usan para no
## depender del reloj.
func set_lit(level: float) -> void:
	_level = clampf(level, 0.0, 1.0)
	visible = _level >= MIN_LEVEL
	if _light != null:
		_light.light_energy = MAX_ENERGY * _level


func get_level() -> float:
	return _level


func get_light() -> OmniLight3D:
	return _light


## Nivel que pide el reloj: uno con la noche cerrada, cero con sol.
func _target_level() -> float:
	var clock: WorldClockService = WorldClockService.instance()
	if clock == null:
		return 0.0
	var daylight: float = DayNightCycle.daylight_at(clock.get_minute_of_day())
	if daylight >= OFF_DAYLIGHT:
		return 0.0
	return 1.0 - smoothstep(0.0, OFF_DAYLIGHT, daylight)


func _build_torch() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	_visual.scale = Vector3.ONE * VISUAL_SCALE
	add_child(_visual)
	var wood: StandardMaterial3D = _material(Color(0.30, 0.20, 0.11, 1.0), 0.95)
	var straw: StandardMaterial3D = _material(Color(0.62, 0.48, 0.26, 1.0), 0.9)
	var ember: StandardMaterial3D = _ember_material()
	var stick: MeshInstance3D = MeshInstance3D.new()
	var shaft: CylinderMesh = CylinderMesh.new()
	shaft.top_radius = 0.012
	shaft.bottom_radius = 0.016
	shaft.height = 0.52
	shaft.radial_segments = 7
	stick.mesh = shaft
	stick.material_override = wood
	_visual.add_child(stick)
	var band: MeshInstance3D = MeshInstance3D.new()
	var wrap_mesh: CylinderMesh = CylinderMesh.new()
	wrap_mesh.top_radius = 0.040
	wrap_mesh.bottom_radius = 0.030
	wrap_mesh.height = 0.16
	wrap_mesh.radial_segments = 8
	band.mesh = wrap_mesh
	band.material_override = straw
	band.position = Vector3(0.0, 0.30, 0.0)
	_visual.add_child(band)
	# Llama: una punta cónica sobre una base redonda. La esfera sola se leía
	# como una bombilla encendida, no como fuego.
	var flame: MeshInstance3D = MeshInstance3D.new()
	var tongue: CylinderMesh = CylinderMesh.new()
	tongue.top_radius = 0.006
	tongue.bottom_radius = 0.042
	tongue.height = 0.17
	tongue.radial_segments = 8
	flame.mesh = tongue
	flame.material_override = ember
	flame.position = Vector3(0.0, 0.44, 0.0)
	_visual.add_child(flame)
	var base: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.046
	sphere.height = 0.09
	sphere.radial_segments = 8
	sphere.rings = 4
	base.mesh = sphere
	base.material_override = ember
	base.position = Vector3(0.0, 0.36, 0.0)
	_visual.add_child(base)
	_build_hand(Vector3(0.0, -0.12, 0.0))
	_light = OmniLight3D.new()
	_light.name = "Light"
	_light.position = Vector3(0.0, 0.42 * VISUAL_SCALE, 0.0)
	_light.light_color = LIGHT_COLOR
	_light.omni_range = LIGHT_RANGE
	_light.light_energy = 0.0
	_light.light_specular = 0.25
	# Sin sombras: una luz con sombra en primera persona cuesta caro y la
	# antorcha alumbra, no recorta la escena.
	_light.shadow_enabled = false
	add_child(_light)


## Mano de agarre del maniquí, con los mismos ejes que el arma en primera
## persona: X mango, Z antebrazo hacia la cámara, Y palma y dedos.
func _build_hand(at: Vector3) -> void:
	var hand: MannequinHand = MannequinHand.new()
	hand.name = "GripHand"
	hand.grip = true
	# Solo el puño: el antebrazo del maniquí mide 1,8 m y a esta distancia se
	# come media pantalla. El brazo queda fuera de cuadro, como en un arma en
	# primera persona.
	hand.show_forearm = false
	hand.scale = Vector3.ONE * 0.9
	var hand_z: Vector3 = Vector3(0.22, -0.94, 0.26).normalized()
	var hand_x: Vector3 = Vector3(0.0, 1.0, 0.0)
	var hand_y: Vector3 = hand_z.cross(hand_x).normalized()
	var origin: Vector3 = at + hand_y * 0.03 + hand_z * 0.09
	hand.transform = Transform3D(Basis(hand_x, hand_y, hand_z), origin)
	_visual.add_child(hand)


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


func _ember_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = _material(Color(1.0, 0.55, 0.18, 1.0), 0.7)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.52, 0.16)
	material.emission_energy_multiplier = 3.0
	return material
