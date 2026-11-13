class_name StoneWall
extends RefCounted
## Cara de muro de piedra de campo generada en Godot para los muros de
## contención de las terrazas (alcance §6.1: malla
## procedural; ficha PCH-008, reconstrucción R).
##
## Cada cara se llena de hiladas de piedras irregulares que sobresalen un poco
## del bloque de colisión; el bloque asoma entre ellas como junta (oscura,
## de piedra seca, en las terrazas). Una sola malla con color por vértice por terraza: una llamada de
## dibujo. El reparto es determinista para una semilla dada.

const COURSE_MIN: float = 0.2
const COURSE_MAX: float = 0.34
## Primera hilada: piedras grandes que asientan el muro.
const BASE_COURSE_MIN: float = 0.34
const BASE_COURSE_MAX: float = 0.46
const STONE_MIN: float = 0.28
const STONE_MAX: float = 0.7
const BASE_STONE_MIN: float = 0.55
const BASE_STONE_MAX: float = 0.95
const GAP_MIN: float = 0.008
const GAP_MAX: float = 0.018
## Lados del contorno de cada piedra.
const SIDES: int = 5
const PROUD_MIN: float = 0.02
const PROUD_MAX: float = 0.05
const STONE_COLORS: Array[Color] = [
	Color(0.45, 0.42, 0.37, 1.0),
	Color(0.37, 0.35, 0.32, 1.0),
	Color(0.52, 0.48, 0.41, 1.0),
	Color(0.5, 0.41, 0.33, 1.0),
]
## Variación de brillo de cada piedra.
const SHADE_JITTER: float = 0.06


## Cara rectangular de muro: esquina inferior de partida, dirección a lo largo
## de la cara, normal hacia fuera, largo y alto.
class Face:
	var origin: Vector3
	var along: Vector3
	var normal: Vector3
	var length: float
	var height: float

	func _init(face_origin: Vector3, face_along: Vector3, face_normal: Vector3, face_length: float, face_height: float) -> void:
		origin = face_origin
		along = face_along.normalized()
		normal = face_normal.normalized()
		length = face_length
		height = face_height


## Malla de piedras para todas las [param faces], con la semilla [param wall_seed].
## Devuelve también, en [param stats], el número de piedras (clave "stones").
static func build(faces: Array[Face], wall_seed: int, stats: Dictionary = {}) -> ArrayMesh:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = wall_seed
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var stones: int = 0
	for face: Face in faces:
		stones += _fill_face(surface, rng, face)
	stats["stones"] = stones
	surface.generate_normals()
	return surface.commit()


static func _fill_face(surface: SurfaceTool, rng: RandomNumberGenerator, face: Face) -> int:
	var up: Vector3 = Vector3.UP
	var count: int = 0
	var v: float = 0.0
	var first: bool = true
	while v < face.height - 0.06:
		var course: float = rng.randf_range(BASE_COURSE_MIN, BASE_COURSE_MAX) if first else rng.randf_range(COURSE_MIN, COURSE_MAX)
		course = minf(course, face.height - v)
		var u: float = -rng.randf_range(0.0, 0.3)
		while u < face.length:
			var stone_len: float = rng.randf_range(BASE_STONE_MIN, BASE_STONE_MAX) if first else rng.randf_range(STONE_MIN, STONE_MAX)
			var u0: float = maxf(u, 0.0)
			var u1: float = minf(u + stone_len, face.length)
			u += stone_len
			var stone_h: float = course * rng.randf_range(0.86, 1.0)
			var lift: float = rng.randf_range(0.0, course - stone_h)
			var gap: float = rng.randf_range(GAP_MIN, GAP_MAX)
			var proud: float = rng.randf_range(PROUD_MIN, PROUD_MAX) * (1.3 if first else 1.0)
			var color: Color = STONE_COLORS[rng.randi_range(0, STONE_COLORS.size() - 1)]
			var shade: float = rng.randf_range(-SHADE_JITTER, SHADE_JITTER)
			if u1 - u0 < 0.1:
				continue
			color = Color(clampf(color.r + shade, 0.0, 1.0), clampf(color.g + shade, 0.0, 1.0), clampf(color.b + shade, 0.0, 1.0), 1.0)
			# La paleta está en sRGB; el color por vértice va en lineal, como en los
			# modelos de Blender.
			color = color.srgb_to_linear()
			var center: Vector3 = face.origin + face.along * ((u0 + u1) * 0.5) + up * (v + lift + stone_h * 0.5)
			_add_stone(surface, rng, center, face.along, up, face.normal, (u1 - u0) - gap, stone_h - gap, proud, color)
			count += 1
		v += course
		first = false
	return count


## Piedra tosca vista de frente: contorno casi rectangular e irregular en el
## plano del muro (centro [param center], ejes [param axis_u] y
## [param axis_v]), bisel corto y cara plana que sobresale [param proud] hacia
## [param normal]. La base queda en la cara del bloque, que asoma entre las
## piedras como junta.
static func _add_stone(surface: SurfaceTool, rng: RandomNumberGenerator, center: Vector3, axis_u: Vector3, axis_v: Vector3, normal: Vector3, size_u: float, size_v: float, proud: float, color: Color) -> void:
	var phase: float = rng.randf_range(0.0, TAU)
	var tilt: float = rng.randf_range(-0.12, 0.12)
	var inset: float = rng.randf_range(0.94, 0.97)
	var depth: float = proud * rng.randf_range(0.94, 1.0)
	var base: PackedVector3Array = PackedVector3Array()
	var front: PackedVector3Array = PackedVector3Array()
	for k: int in range(SIDES):
		var angle: float = phase + TAU * float(k) / float(SIDES)
		var c: float = cos(angle)
		var s: float = sin(angle)
		# Superelipse casi rectangular: piedra de caras planas, no canto rodado.
		var r: float = 1.0 / pow(pow(absf(c), 6.0) + pow(absf(s), 6.0), 1.0 / 6.0) * rng.randf_range(0.96, 1.02)
		var u: float = c * r * size_u * 0.5
		var w: float = s * r * size_v * 0.5
		var edge: Vector3 = axis_u * (u * cos(tilt) - w * sin(tilt)) + axis_v * (u * sin(tilt) + w * cos(tilt))
		base.append(center + edge)
		front.append(center + edge * inset + normal * depth)
	var face_center: Vector3 = center + normal * depth + (axis_u * rng.randf_range(-0.02, 0.02) * size_u
		+ axis_v * rng.randf_range(-0.02, 0.02) * size_v)
	surface.set_color(color)
	for k: int in range(SIDES):
		var j: int = (k + 1) % SIDES
		_add_triangle(surface, base[k], base[j], front[j], normal)
		_add_triangle(surface, base[k], front[j], front[k], normal)
		_add_triangle(surface, front[k], front[j], face_center, normal)


## Triángulo orientado hacia fuera del muro ([param normal]).
static func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void:
	if (b - a).cross(c - a).dot(normal) > 0.0:
		surface.add_vertex(a)
		surface.add_vertex(c)
		surface.add_vertex(b)
	else:
		surface.add_vertex(a)
		surface.add_vertex(b)
		surface.add_vertex(c)
