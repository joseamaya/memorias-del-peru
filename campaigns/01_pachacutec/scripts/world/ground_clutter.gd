class_name GroundClutter
extends Node3D
## Piedras sueltas sobre la tierra pisada.
##
## El suelo procedural tenía un problema de lectura: a media distancia es una
## alfombra de textura y no hay nada que dé escala. Unas cuantas piedras
## pequeñas, en una sola llamada de dibujo, rompen la uniformidad y anclan a
## los personajes al terreno.
##
## No conoce campañas: recibe la altura del suelo y el área donde sembrar.

## Semilla fija: el reparto es el mismo en cada partida.
const DEFAULT_SEED: int = 7331
## Piedras por cada 100 m².
const DENSITY: float = 2.2
## Radio del grano base, en metros; cada piedra lo multiplica entre 0.4 y 1.6.
const BASE_RADIUS: float = 0.09


## Siembra piedras en un disco de [param radius] alrededor de [param center].
## [param height_source] recibe (x, z) y devuelve la altura del suelo.
## [param skip_radius] deja limpio el centro (la plaza despejada).
func build(height_source: Callable, center: Vector3, radius: float, skip_radius: float = 0.0) -> void:
	if not height_source.is_valid():
		return
	var area: float = PI * maxf(radius * radius - skip_radius * skip_radius, 0.0)
	var count: int = clampi(int(area * DENSITY / 100.0), 40, 1200)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = DEFAULT_SEED
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = _pebble_mesh()
	multimesh.instance_count = count
	var placed: int = 0
	var attempts: int = 0
	while placed < count and attempts < count * 6:
		attempts += 1
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = sqrt(rng.randf_range(skip_radius * skip_radius, radius * radius))
		var x: float = center.x + cos(angle) * distance
		var z: float = center.z + sin(angle) * distance
		var ground: float = height_source.call(x, z)
		var size: float = BASE_RADIUS * rng.randf_range(0.4, 1.6)
		var spin: Basis = Basis(Vector3.UP, rng.randf_range(0.0, TAU))
		spin = spin.scaled(Vector3(size, size * rng.randf_range(0.45, 0.8), size))
		var at: Vector3 = Vector3(x, ground + size * 0.25, z)
		multimesh.set_instance_transform(placed, Transform3D(spin, at))
		placed += 1
	multimesh.instance_count = placed
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "Pebbles"
	instance.multimesh = multimesh
	instance.material_override = _stone_material()
	# Son detalles de suelo: no proyectan sombra ni entran en el GI.
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(instance)


static func _pebble_mesh() -> SphereMesh:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	# Muy pocos segmentos: a 9 cm no se distingue una esfera de ocho caras.
	mesh.radial_segments = 6
	mesh.rings = 3
	return mesh


static func _stone_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.46, 0.43, 0.39, 1.0)
	material.roughness = 0.95
	material.metallic = 0.0
	return material
